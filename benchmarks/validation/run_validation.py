#!/usr/bin/env python3
"""
Master Commercial Parity Validation Runner

Orchestrates iPA vs PTPX and iIR vs Voltus validation campaigns.
Runs analyses on design list, collects reports, generates summaries.
"""

import sys
import json
import subprocess
from pathlib import Path
from typing import List, Dict
import argparse
import time


def run_validation_campaign(
    validation_type: str,
    design_list: List[str],
    output_dir: Path,
    dry_run: bool = False
) -> Dict:
    """Run a validation campaign (iPA or iIR)"""

    print(f"\n{'='*70}")
    print(f"  {validation_type} Commercial Parity Validation")
    print(f"{'='*70}")

    if validation_type == "iPA_vs_PTPX":
        script_dir = output_dir / "iPA_vs_PTPX" / "scripts"
        comparison_script = script_dir / "run_comparison.py"
    elif validation_type == "iIR_vs_Voltus":
        script_dir = output_dir / "iIR_vs_Voltus" / "scripts"
        comparison_script = script_dir / "run_comparison.py"
    else:
        raise ValueError(f"Unknown validation type: {validation_type}")

    # Write design list
    design_list_file = output_dir / f"{validation_type}_designs.txt"
    with open(design_list_file, 'w') as f:
        for design in design_list:
            f.write(f"{design}\n")

    print(f"\nDesign list ({len(design_list)} designs):")
    for design in design_list:
        print(f"  - {design}")

    if dry_run:
        print("\n[DRY RUN] Would run:")
        print(f"  python {comparison_script} --design-list {design_list_file}")
        return {'dry_run': True}

    # Run comparison
    print(f"\nRunning {validation_type} comparison...")
    start_time = time.time()

    result_file = output_dir / f"{validation_type}_results.json"
    cmd = [
        sys.executable,
        str(comparison_script),
        "--design-list", str(design_list_file),
        "--output", str(result_file),
    ]

    try:
        subprocess.run(cmd, check=True, cwd=script_dir.parent)
        elapsed = time.time() - start_time

        # Load results
        with open(result_file) as f:
            results = json.load(f)

        results['elapsed_time_s'] = elapsed
        print(f"\n✓ {validation_type} validation complete ({elapsed:.1f}s)")
        return results

    except subprocess.CalledProcessError as e:
        print(f"\n✗ {validation_type} validation failed: {e}")
        return {'error': str(e)}


def generate_summary_report(
    ipa_results: Dict,
    iir_results: Dict,
    output_path: Path
):
    """Generate markdown summary report"""

    with open(output_path, 'w') as f:
        f.write("# iPA/iIR Commercial Parity Validation Summary\n\n")
        f.write(f"Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        # iPA vs PTPX summary
        f.write("## iPA vs PrimeTime PX\n\n")
        if 'error' in ipa_results:
            f.write(f"**ERROR**: {ipa_results['error']}\n\n")
        elif 'dry_run' in ipa_results:
            f.write("_Dry run only_\n\n")
        else:
            passed = ipa_results.get('passed', 0)
            total = ipa_results.get('num_designs', 0)
            f.write(f"**Status**: {passed}/{total} designs PASSED\n\n")

            f.write("| Design | Total Power Error | Activity Source | Status |\n")
            f.write("|--------|-------------------|-----------------|--------|\n")

            for result in ipa_results.get('results', []):
                design = result['design']
                error_pct = result['errors_pct']['total']
                activity = result['ipa']['activity_source']
                status = "✓ PASS" if result['passed'] else "✗ FAIL"
                f.write(f"| {design} | {error_pct:+.2f}% | {activity} | {status} |\n")

            f.write("\n")

        # iIR vs Voltus summary
        f.write("## iIR vs Voltus\n\n")
        if 'error' in iir_results:
            f.write(f"**ERROR**: {iir_results['error']}\n\n")
        elif 'dry_run' in iir_results:
            f.write("_Dry run only_\n\n")
        else:
            passed = iir_results.get('passed', 0)
            total = iir_results.get('num_designs', 0)
            f.write(f"**Status**: {passed}/{total} designs PASSED\n\n")

            f.write("| Design | Peak IR Error | Converged | Mapping Coverage | Status |\n")
            f.write("|--------|---------------|-----------|------------------|--------|\n")

            for result in iir_results.get('results', []):
                design = result['design']
                error_mv = result['errors']['peak_ir_mv']
                converged = "✓" if result['convergence']['iir_converged'] else "✗"
                coverage = result['iir']['mapping_coverage'] if 'mapping_coverage' in result['iir'] else 0.0
                status = "✓ PASS" if result['passed'] else "✗ FAIL"
                f.write(f"| {design} | {error_mv:+.2f} mV | {converged} | {coverage:.1%} | {status} |\n")

            f.write("\n")

        # Gate summary
        f.write("## Gate Status\n\n")

        ipa_pass = ipa_results.get('passed', 0) == ipa_results.get('num_designs', 0) if 'num_designs' in ipa_results else False
        iir_pass = iir_results.get('passed', 0) == iir_results.get('num_designs', 0) if 'num_designs' in iir_results else False

        f.write(f"- **G9 (iPA activity source honesty)**: {'✓ PASS' if ipa_pass else '✗ FAIL'}\n")
        f.write(f"- **G10 (iIR convergence gate)**: {'✓ PASS' if iir_pass else '✗ FAIL'}\n")
        f.write(f"- **G17 (power signoff accuracy)**: {'✓ PASS' if ipa_pass else '✗ FAIL'}\n\n")

        overall = "✓ ALL GATES PASSED" if (ipa_pass and iir_pass) else "✗ SOME GATES FAILED"
        f.write(f"### Overall: {overall}\n")

    print(f"\nSummary report written to {output_path}")


def main():
    parser = argparse.ArgumentParser(description='Master commercial parity validation runner')
    parser.add_argument('--design-list', required=True, help='Design list file')
    parser.add_argument('--output-dir', default='benchmarks/validation', help='Output directory')
    parser.add_argument('--dry-run', action='store_true', help='Dry run only')
    parser.add_argument('--skip-ipa', action='store_true', help='Skip iPA validation')
    parser.add_argument('--skip-iir', action='store_true', help='Skip iIR validation')
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Load design list
    with open(args.design_list) as f:
        lines = [line.strip() for line in f if line.strip() and not line.startswith('#')]

    # Parse design list (format: design|pdk|activity|budget|notes)
    ipa_designs = []
    iir_designs = []

    for line in lines:
        if '|' not in line:
            continue

        parts = line.split('|')
        design = parts[0].strip()

        # Add to appropriate list based on context
        # For now, assume all designs run both validations
        ipa_designs.append(design)
        iir_designs.append(design)

    # Run validations
    ipa_results = {}
    iir_results = {}

    if not args.skip_ipa:
        ipa_results = run_validation_campaign(
            "iPA_vs_PTPX",
            ipa_designs,
            output_dir,
            dry_run=args.dry_run
        )

    if not args.skip_iir:
        iir_results = run_validation_campaign(
            "iIR_vs_Voltus",
            iir_designs,
            output_dir,
            dry_run=args.dry_run
        )

    # Generate summary
    summary_path = output_dir / "validation_summary.md"
    generate_summary_report(ipa_results, iir_results, summary_path)

    # Overall exit status
    if args.dry_run:
        return 0

    ipa_ok = ipa_results.get('passed', 0) == ipa_results.get('num_designs', 0) if not args.skip_ipa else True
    iir_ok = iir_results.get('passed', 0) == iir_results.get('num_designs', 0) if not args.skip_iir else True

    return 0 if (ipa_ok and iir_ok) else 1


if __name__ == '__main__':
    sys.exit(main())
