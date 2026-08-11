#!/usr/bin/env python3
"""
iIR vs Voltus Commercial Parity Validation Driver

Runs iIR static IR analysis and compares against Voltus reference data.
Gates on convergence, peak IR accuracy, and false clean detection.
"""

import json
import subprocess
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Optional, Dict, List, Tuple
import argparse
import math


@dataclass
class IRNode:
    """Single PG node with IR drop"""
    name: str
    x: float
    y: float
    layer: str
    ir_drop_mv: float
    voltage_v: float


@dataclass
class IRReport:
    """Complete IR analysis report with convergence metrics"""
    peak_ir_mv: float
    nominal_voltage_mv: float
    budget_mv: float
    converged: bool
    iterations: int
    absolute_residual: float
    relative_residual: float
    current_source: str  # "iPA_vcd" | "iPA_saif" | "iPA_default" | "ptpx" | "none"

    # Top-N worst nodes
    top_nodes: List[IRNode]

    # Current mapping trace (P1 requirement)
    total_power_instances: int = 0
    mapped_instances: int = 0
    unmatched_instances: int = 0
    mapped_power_w: float = 0.0

    runtime_s: Optional[float] = None
    solver_method: Optional[str] = None

    @property
    def budget_utilization(self) -> float:
        """Peak IR as % of budget"""
        return (self.peak_ir_mv / self.budget_mv) if self.budget_mv > 0 else 0.0

    @property
    def mapping_coverage(self) -> float:
        """Instance mapping coverage"""
        return (self.mapped_instances / self.total_power_instances
                if self.total_power_instances > 0 else 0.0)


@dataclass
class IRComparisonResult:
    """Comparison between iIR and Voltus"""
    design: str
    iir_report: IRReport
    voltus_report: IRReport

    # Error metrics
    peak_ir_error_mv: float
    peak_ir_error_pct: float

    # Node correlation
    top_n_spearman_rho: float  # Rank correlation for top-N nodes
    top_n_node_swaps: int  # How many top-10 nodes swapped rank

    # Convergence validation
    iir_converged: bool
    voltus_converged: bool
    residual_ratio: float  # iIR_residual / Voltus_residual

    # False clean detection
    is_false_clean: bool  # iIR clean but Voltus has violations

    # Gate status
    passed: bool
    warnings: List[str]
    errors: List[str]

    def to_dict(self) -> Dict:
        return {
            'design': self.design,
            'iir': asdict(self.iir_report),
            'voltus': asdict(self.voltus_report),
            'errors': {
                'peak_ir_mv': self.peak_ir_error_mv,
                'peak_ir_pct': self.peak_ir_error_pct,
            },
            'correlation': {
                'spearman_rho': self.top_n_spearman_rho,
                'top_10_swaps': self.top_n_node_swaps,
            },
            'convergence': {
                'iir_converged': self.iir_converged,
                'voltus_converged': self.voltus_converged,
                'residual_ratio': self.residual_ratio,
            },
            'false_clean': self.is_false_clean,
            'passed': self.passed,
            'warnings': self.warnings,
            'errors': self.errors,
        }


def parse_iir_report(json_path: Path) -> IRReport:
    """Parse iIR JSON IR report

    Expected schema (per 29-iPA-iIR-todo.md P0):
    {
      "peak_ir_mv": 45.2,
      "budget_mv": 50.0,
      "converged": true,
      "iterations": 87,
      "absolute_residual": 1.23e-8,
      "relative_residual": 5.67e-7,
      "current_source": "iPA_vcd",
      "top_nodes": [
        {"name": "VDD_inst123", "x": 100.5, "y": 200.3, "layer": "met5",
         "ir_drop_mv": 45.2, "voltage_v": 1.0548},
        ...
      ],
      "mapping_trace": {
        "total_power_instances": 7000,
        "mapped_instances": 6850,
        "unmatched_instances": 150,
        "mapped_power_w": 0.0123
      }
    }
    """
    with open(json_path) as f:
        data = json.load(f)

    # Validate required fields (P0 convergence gate)
    required = ['peak_ir_mv', 'budget_mv', 'converged', 'iterations',
                'absolute_residual', 'relative_residual', 'current_source']
    for field in required:
        if field not in data:
            raise ValueError(f"iIR report missing required field: {field}")

    # Parse top nodes
    top_nodes = []
    for node_data in data.get('top_nodes', []):
        top_nodes.append(IRNode(
            name=node_data['name'],
            x=node_data['x'],
            y=node_data['y'],
            layer=node_data['layer'],
            ir_drop_mv=node_data['ir_drop_mv'],
            voltage_v=node_data['voltage_v'],
        ))

    # Parse mapping trace
    trace = data.get('mapping_trace', {})

    return IRReport(
        peak_ir_mv=data['peak_ir_mv'],
        nominal_voltage_mv=data.get('nominal_voltage_mv', 1000.0),
        budget_mv=data['budget_mv'],
        converged=data['converged'],
        iterations=data['iterations'],
        absolute_residual=data['absolute_residual'],
        relative_residual=data['relative_residual'],
        current_source=data['current_source'],
        top_nodes=top_nodes,
        total_power_instances=trace.get('total_power_instances', 0),
        mapped_instances=trace.get('mapped_instances', 0),
        unmatched_instances=trace.get('unmatched_instances', 0),
        mapped_power_w=trace.get('mapped_power_w', 0.0),
        runtime_s=data.get('runtime_s'),
        solver_method=data.get('solver_method', 'CG'),
    )


def parse_voltus_report(rpt_path: Path) -> IRReport:
    """Parse Voltus text IR report

    Voltus report format (example):
    ----------------------------------------
    IR Drop Analysis Summary
    Maximum IR Drop: 47.8 mV at node VDD_inst456 (x=102.3, y=198.7, layer=met5)
    Nominal Voltage: 1.0 V
    Budget: 50.0 mV
    Convergence: Yes (92 iterations)
    Residual: 3.45e-8 (relative: 8.12e-7)

    Top 10 Worst Nodes:
    Rank | Node Name    | Location       | IR Drop (mV) | Voltage (V)
    -----|-------------|----------------|--------------|-------------
    1    | VDD_inst456 | (102.3, 198.7) | 47.8         | 1.0522
    2    | VDD_inst789 | (105.1, 201.2) | 46.3         | 1.0537
    ...
    ----------------------------------------
    """
    peak_ir = 0.0
    budget = 0.0
    converged = False
    iterations = 0
    abs_residual = 0.0
    rel_residual = 0.0
    top_nodes = []

    with open(rpt_path) as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        line = line.strip()

        if 'Maximum IR Drop:' in line:
            parts = line.split()
            peak_ir = float(parts[3])  # "47.8" from "Maximum IR Drop: 47.8 mV"
        elif 'Budget:' in line:
            budget = float(line.split()[1])
        elif 'Convergence:' in line:
            converged = 'Yes' in line
            if '(' in line:
                iterations = int(line.split('(')[1].split()[0])
        elif 'Residual:' in line:
            parts = line.split()
            abs_residual = float(parts[1])
            if 'relative:' in line:
                rel_residual = float(parts[3].rstrip(')'))
        elif '|' in line and 'Rank' not in line and len(line.split('|')) == 5:
            # Parse top node table rows
            cols = [c.strip() for c in line.split('|')]
            if len(cols) == 5 and cols[0].isdigit():
                rank, name, loc, ir_mv, voltage = cols
                # Parse location "(x, y)"
                loc_clean = loc.strip('()')
                x, y = map(float, loc_clean.split(','))

                top_nodes.append(IRNode(
                    name=name,
                    x=x,
                    y=y,
                    layer='met5',  # Default, parse if available
                    ir_drop_mv=float(ir_mv),
                    voltage_v=float(voltage),
                ))

    return IRReport(
        peak_ir_mv=peak_ir,
        nominal_voltage_mv=1000.0,  # Default 1V
        budget_mv=budget,
        converged=converged,
        iterations=iterations,
        absolute_residual=abs_residual,
        relative_residual=rel_residual,
        current_source="ptpx",  # Assume PTPX for reference
        top_nodes=top_nodes,
    )


def spearman_rank_correlation(iir_nodes: List[IRNode], voltus_nodes: List[IRNode]) -> float:
    """Compute Spearman rank correlation for top-N nodes

    Matches nodes by name, computes rank difference squared sum.
    """
    # Build rank maps (1-indexed)
    iir_ranks = {node.name: i+1 for i, node in enumerate(iir_nodes)}
    voltus_ranks = {node.name: i+1 for i, node in enumerate(voltus_nodes)}

    # Find common nodes
    common = set(iir_ranks.keys()) & set(voltus_ranks.keys())
    if not common:
        return 0.0  # No overlap

    # Spearman's ρ = 1 - (6 Σd²) / (n(n²-1))
    n = len(common)
    d_squared_sum = sum((iir_ranks[name] - voltus_ranks[name])**2 for name in common)

    if n < 2:
        return 1.0 if n == 1 else 0.0

    rho = 1.0 - (6.0 * d_squared_sum) / (n * (n*n - 1))
    return rho


def count_top_n_swaps(iir_nodes: List[IRNode], voltus_nodes: List[IRNode], n: int = 10) -> int:
    """Count how many of top-N nodes swapped ranks between iIR and Voltus"""
    iir_top_n = {node.name for node in iir_nodes[:n]}
    voltus_top_n = {node.name for node in voltus_nodes[:n]}

    # Nodes in one top-N but not the other = swaps
    return len(iir_top_n ^ voltus_top_n)


def compare_ir_reports(design: str, iir: IRReport, voltus: IRReport) -> IRComparisonResult:
    """Compare iIR vs Voltus and gate on accuracy + convergence"""

    # Error metrics
    peak_err_mv = iir.peak_ir_mv - voltus.peak_ir_mv
    peak_err_pct = (peak_err_mv / voltus.peak_ir_mv * 100.0) if voltus.peak_ir_mv > 0 else 0.0

    # Node correlation
    spearman_rho = spearman_rank_correlation(iir.top_nodes, voltus.top_nodes)
    top_10_swaps = count_top_n_swaps(iir.top_nodes, voltus.top_nodes, n=10)

    # Convergence
    residual_ratio = (iir.relative_residual / voltus.relative_residual
                     if voltus.relative_residual > 0 else 1.0)

    # False clean: Voltus has violations (>budget) but iIR reports clean (<budget)
    voltus_has_violations = voltus.peak_ir_mv > voltus.budget_mv
    iir_reports_clean = iir.peak_ir_mv <= iir.budget_mv
    is_false_clean = voltus_has_violations and iir_reports_clean

    warnings = []
    errors = []

    # Gate 1: Convergence (G10 requirement)
    if not iir.converged:
        errors.append(f"iIR did not converge (iterations={iir.iterations}, residual={iir.relative_residual:.2e})")

    # Gate 2: Peak IR accuracy (±5mV or ±10%, whichever larger)
    threshold_mv = max(5.0, abs(voltus.peak_ir_mv * 0.10))
    if abs(peak_err_mv) > threshold_mv:
        if abs(peak_err_mv) > max(10.0, abs(voltus.peak_ir_mv * 0.15)):
            errors.append(f"Peak IR error {peak_err_mv:+.2f} mV ({peak_err_pct:+.1f}%) exceeds ±10mV/±15% threshold")
        else:
            warnings.append(f"Peak IR error {peak_err_mv:+.2f} mV ({peak_err_pct:+.1f}%) exceeds ±5mV/±10% target")

    # Gate 3: Top-N correlation (warn if Spearman ρ < 0.8 or >2 top-10 swaps)
    if spearman_rho < 0.8:
        warnings.append(f"Top-N rank correlation {spearman_rho:.3f} below 0.8 target")
    if top_10_swaps > 2:
        warnings.append(f"{top_10_swaps} top-10 nodes swapped ranks (threshold: 2)")

    # Gate 4: False clean detection (critical error)
    if is_false_clean:
        errors.append(f"False clean: Voltus peak {voltus.peak_ir_mv:.1f}mV > budget {voltus.budget_mv:.1f}mV, "
                     f"but iIR peak {iir.peak_ir_mv:.1f}mV < budget {iir.budget_mv:.1f}mV")

    # Gate 5: Current source mapping (P1 requirement, warn if <90% coverage)
    if iir.mapping_coverage < 0.9:
        warnings.append(f"Current mapping coverage {iir.mapping_coverage:.1%} below 90% "
                       f"({iir.mapped_instances}/{iir.total_power_instances} instances)")

    # Gate 6: Current source provenance (must not be "none")
    if iir.current_source == "none":
        errors.append("Current source 'none' not acceptable for IR analysis")

    passed = len(errors) == 0

    return IRComparisonResult(
        design=design,
        iir_report=iir,
        voltus_report=voltus,
        peak_ir_error_mv=peak_err_mv,
        peak_ir_error_pct=peak_err_pct,
        top_n_spearman_rho=spearman_rho,
        top_n_node_swaps=top_10_swaps,
        iir_converged=iir.converged,
        voltus_converged=voltus.converged,
        residual_ratio=residual_ratio,
        is_false_clean=is_false_clean,
        passed=passed,
        warnings=warnings,
        errors=errors,
    )


def main():
    parser = argparse.ArgumentParser(description='iIR vs Voltus validation')
    parser.add_argument('--design-list', required=True, help='Text file with design names')
    parser.add_argument('--output', default='validation_results.json', help='Output JSON path')
    args = parser.parse_args()

    with open(args.design_list) as f:
        designs = [line.strip() for line in f if line.strip()]

    results = []
    for design in designs:
        print(f"\n=== Validating {design} ===")

        base_path = Path(__file__).parent / 'designs' / design
        iir_json = base_path / 'iIR_report.json'
        voltus_rpt = base_path / 'voltus_report.rpt'

        if not iir_json.exists():
            print(f"ERROR: iIR report not found: {iir_json}")
            continue
        if not voltus_rpt.exists():
            print(f"WARN: Voltus report not found: {voltus_rpt}, skipping comparison")
            continue

        try:
            iir = parse_iir_report(iir_json)
            voltus = parse_voltus_report(voltus_rpt)
            result = compare_ir_reports(design, iir, voltus)

            print(f"  Peak IR: iIR={iir.peak_ir_mv:.1f}mV  Voltus={voltus.peak_ir_mv:.1f}mV  "
                  f"Error={result.peak_ir_error_mv:+.2f}mV ({result.peak_ir_error_pct:+.1f}%)")
            print(f"  Convergence: iIR={'✓' if iir.converged else '✗'}  Voltus={'✓' if voltus.converged else '✗'}")
            print(f"  Current mapping: {iir.mapping_coverage:.1%} ({iir.mapped_instances}/{iir.total_power_instances})")
            print(f"  Rank correlation: ρ={result.top_n_spearman_rho:.3f}  Swaps={result.top_n_node_swaps}")
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
            'validation_type': 'iIR_vs_Voltus',
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
