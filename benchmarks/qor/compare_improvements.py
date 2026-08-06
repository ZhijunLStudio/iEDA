#!/usr/bin/env python3
# ***************************************************************************************
# Copyright (c) 2023-2025 Peng Cheng Laboratory
# Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
# Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
#
# iEDA is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
# http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
#
# See the Mulan PSL v2 for more details.
# ***************************************************************************************
"""
改进效果对比工具
用于对比 iRT 改进前后的收敛性、质量和性能
"""

import json
import sys
import re
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime


def extract_routing_metrics(result_dir: Path) -> Dict:
    """从结果目录提取布线指标"""
    metrics = {
        "convergence": {},
        "quality": {},
        "performance": {},
        "stability": {}
    }

    # 1. 解析 rt.log 提取收敛信息
    rt_log = result_dir / "workspace/result/rt/rt.log"
    if rt_log.exists():
        metrics["convergence"] = parse_routing_log(rt_log)

    # 2. 解析 plateau_diagnostic.json（如果有）
    plateau_json = result_dir / "workspace/result/plateau_diagnostic.json"
    if plateau_json.exists():
        with open(plateau_json) as f:
            plateau = json.load(f)
            metrics["stability"]["plateau_detected"] = plateau.get("plateau_detected", False)
            metrics["convergence"]["boxes_completed"] = plateau.get("box_progress", "0/0")

    # 3. 解析 memory_diagnostic.json（如果有）
    memory_json = result_dir / "workspace/result/memory_diagnostic.json"
    if memory_json.exists():
        with open(memory_json) as f:
            memory = json.load(f)
            metrics["stability"]["oom_occurred"] = memory.get("memory_budget_exceeded", False)
            metrics["performance"]["peak_memory_mb"] = memory.get("current_memory_mb", 0)

    # 4. 解析 DRC 结果
    drc_log = result_dir / "workspace/result/rt/other_tools/idrc/drc.log"
    if drc_log.exists():
        metrics["quality"]["drc_count"] = parse_drc_count(drc_log)

    # 5. 提取运行时间（从 rt.log 或时间戳）
    if rt_log.exists():
        metrics["performance"]["wall_time_sec"] = extract_wall_time(rt_log)

    return metrics


def parse_routing_log(log_path: Path) -> Dict:
    """解析 rt.log 提取违例趋势"""
    violations_trend = []
    boxes_completed = "0/0"
    iterations_completed = "0/9"
    routing_completed = False

    try:
        with open(log_path, encoding='utf-8', errors='ignore') as f:
            content = f.read()

            # 匹配: "Routed 36/324 (11%) - 57,929 violations"
            # 或类似的格式
            box_pattern = re.compile(r'Routed\s+(\d+)/(\d+)\s+\([\d.]+%\)\s+-\s+([\d,]+)\s+violations', re.IGNORECASE)

            for match in box_pattern.finditer(content):
                completed = int(match.group(1))
                total = int(match.group(2))
                viols = int(match.group(3).replace(',', ''))

                boxes_completed = f"{completed}/{total}"
                violations_trend.append(viols)

                if completed == total:
                    routing_completed = True

            # 匹配迭代信息: "Begin iteration 3/9"
            iter_pattern = re.compile(r'Begin iteration\s+(\d+)/(\d+)', re.IGNORECASE)
            iter_matches = list(iter_pattern.finditer(content))
            if iter_matches:
                last_iter = iter_matches[-1]
                iterations_completed = f"{last_iter.group(1)}/{last_iter.group(2)}"

    except Exception as e:
        print(f"Warning: Failed to parse {log_path}: {e}", file=sys.stderr)

    return {
        "boxes_completed": boxes_completed,
        "iterations_completed": iterations_completed,
        "routing_completed": routing_completed,
        "violation_trend": violations_trend,
        "final_violations": violations_trend[-1] if violations_trend else 0
    }


def parse_drc_count(drc_log: Path) -> int:
    """解析 DRC 总数"""
    try:
        with open(drc_log, encoding='utf-8', errors='ignore') as f:
            content = f.read()
            # 匹配 "Total violations: 1234"
            match = re.search(r'Total violations:\s*(\d+)', content, re.IGNORECASE)
            if match:
                return int(match.group(1))

            # 或者匹配 "DRC count: 1234"
            match = re.search(r'DRC count:\s*(\d+)', content, re.IGNORECASE)
            if match:
                return int(match.group(1))
    except Exception as e:
        print(f"Warning: Failed to parse DRC from {drc_log}: {e}", file=sys.stderr)

    return 0


def extract_wall_time(log_path: Path) -> float:
    """从日志提取墙钟时间（秒）"""
    try:
        with open(log_path, encoding='utf-8', errors='ignore') as f:
            content = f.read()
            # 匹配 "Total time: 1234.56s" 或类似格式
            match = re.search(r'Total time:\s*([\d.]+)\s*s', content, re.IGNORECASE)
            if match:
                return float(match.group(1))

            # 或者从第一行和最后一行的时间戳计算
            lines = content.strip().split('\n')
            if len(lines) >= 2:
                # 简化处理：假设日志包含时间戳
                pass
    except Exception as e:
        print(f"Warning: Failed to extract wall time from {log_path}: {e}", file=sys.stderr)

    return 0.0


def compare_runs(baseline: Dict, improved: Dict) -> Dict:
    """对比两次运行"""
    comparison = {
        "improvement_id": improved.get("improvement_id", "unknown"),
        "convergence_improvement": {},
        "quality_improvement": {},
        "performance_impact": {},
        "stability_improvement": {}
    }

    # 收敛性对比
    baseline_boxes = baseline["convergence"].get("boxes_completed", "0/324")
    improved_boxes = improved["convergence"].get("boxes_completed", "0/324")

    baseline_num = int(baseline_boxes.split("/")[0])
    improved_num = int(improved_boxes.split("/")[0])
    total_boxes = int(baseline_boxes.split("/")[1])

    comparison["convergence_improvement"]["boxes_delta"] = improved_num - baseline_num
    comparison["convergence_improvement"]["boxes_pct"] = \
        (improved_num - baseline_num) / total_boxes * 100
    comparison["convergence_improvement"]["baseline_boxes"] = baseline_boxes
    comparison["convergence_improvement"]["improved_boxes"] = improved_boxes

    # 违例趋势对比
    baseline_viols = baseline["convergence"].get("violation_trend", [])
    improved_viols = improved["convergence"].get("violation_trend", [])

    if baseline_viols and improved_viols:
        min_len = min(len(baseline_viols), len(improved_viols))
        comparison["convergence_improvement"]["final_violations_delta"] = \
            improved_viols[min_len-1] - baseline_viols[min_len-1]
        comparison["convergence_improvement"]["baseline_final_violations"] = baseline_viols[-1]
        comparison["convergence_improvement"]["improved_final_violations"] = improved_viols[-1]

    # 稳定性对比
    comparison["stability_improvement"] = {
        "baseline_plateau": baseline["stability"].get("plateau_detected", False),
        "improved_plateau": improved["stability"].get("plateau_detected", False),
        "baseline_oom": baseline["stability"].get("oom_occurred", False),
        "improved_oom": improved["stability"].get("oom_occurred", False),
        "baseline_completed": baseline["convergence"].get("routing_completed", False),
        "improved_completed": improved["convergence"].get("routing_completed", False)
    }

    # 性能对比
    baseline_time = baseline["performance"].get("wall_time_sec", 0.0)
    improved_time = improved["performance"].get("wall_time_sec", 0.0)

    comparison["performance_impact"]["baseline_time_sec"] = baseline_time
    comparison["performance_impact"]["improved_time_sec"] = improved_time
    if baseline_time > 0:
        comparison["performance_impact"]["time_delta_sec"] = improved_time - baseline_time
        comparison["performance_impact"]["time_delta_pct"] = \
            (improved_time - baseline_time) / baseline_time * 100

    # 质量对比
    baseline_drc = baseline["quality"].get("drc_count", 0)
    improved_drc = improved["quality"].get("drc_count", 0)

    comparison["quality_improvement"]["baseline_drc"] = baseline_drc
    comparison["quality_improvement"]["improved_drc"] = improved_drc
    comparison["quality_improvement"]["drc_delta"] = improved_drc - baseline_drc

    return comparison


def generate_report(comparisons: List[Dict], output_path: Path):
    """生成 Markdown 报告"""
    with open(output_path, "w", encoding='utf-8') as f:
        f.write("# iRT 改进效果对比报告\n\n")
        f.write(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        for comp in comparisons:
            f.write(f"## {comp['improvement_id']}\n\n")

            f.write("### 收敛性改进\n\n")
            conv = comp['convergence_improvement']
            f.write(f"- **Boxes 完成**: {conv.get('baseline_boxes', 'N/A')} → {conv.get('improved_boxes', 'N/A')}\n")
            f.write(f"- **Boxes 提升**: {conv.get('boxes_delta', 0)} ({conv.get('boxes_pct', 0):.1f}%)\n")

            if 'baseline_final_violations' in conv:
                f.write(f"- **最终违例数**: {conv['baseline_final_violations']} → {conv['improved_final_violations']}\n")
                f.write(f"- **违例数变化**: {conv.get('final_violations_delta', 0)}\n")

            f.write("\n### 稳定性改进\n\n")
            stab = comp['stability_improvement']
            f.write(f"- **Plateau 检测**: {stab['baseline_plateau']} → {stab['improved_plateau']}\n")
            f.write(f"- **OOM 发生**: {stab['baseline_oom']} → {stab['improved_oom']}\n")
            f.write(f"- **路由完成**: {stab['baseline_completed']} → {stab['improved_completed']}\n")

            f.write("\n### 性能影响\n\n")
            perf = comp['performance_impact']
            if perf.get('baseline_time_sec', 0) > 0:
                f.write(f"- **墙钟时间**: {perf['baseline_time_sec']:.1f}s → {perf['improved_time_sec']:.1f}s\n")
                f.write(f"- **时间变化**: {perf.get('time_delta_sec', 0):.1f}s ({perf.get('time_delta_pct', 0):.1f}%)\n")
            else:
                f.write("- 时间数据不可用\n")

            f.write("\n### 质量对比\n\n")
            qual = comp['quality_improvement']
            f.write(f"- **DRC 数量**: {qual['baseline_drc']} → {qual['improved_drc']}\n")
            f.write(f"- **DRC 变化**: {qual['drc_delta']}\n")

            f.write("\n---\n\n")


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Compare iRT improvement effects')
    parser.add_argument('--baseline', type=Path, help='Baseline result directory')
    parser.add_argument('--improved', type=Path, help='Improved result directory')
    parser.add_argument('--improvement-id', type=str, help='Improvement identifier')
    parser.add_argument('--experiments', type=Path, help='Directory containing all experiments')
    parser.add_argument('--output', type=Path, default=Path('comparison_report.md'),
                        help='Output report path')

    args = parser.parse_args()

    comparisons = []

    if args.experiments:
        # 批量对比模式
        baseline_dir = args.experiments / "baseline"
        if not baseline_dir.exists():
            print(f"Error: Baseline directory not found: {baseline_dir}", file=sys.stderr)
            return 1

        baseline_metrics = extract_routing_metrics(baseline_dir)

        for exp_dir in sorted(args.experiments.iterdir()):
            if exp_dir.is_dir() and exp_dir.name.startswith("E-") and exp_dir != baseline_dir:
                print(f"Processing experiment: {exp_dir.name}")
                improved_metrics = extract_routing_metrics(exp_dir)
                improved_metrics["improvement_id"] = exp_dir.name

                comparison = compare_runs(baseline_metrics, improved_metrics)
                comparisons.append(comparison)

    elif args.baseline and args.improved:
        # 单次对比模式
        baseline_metrics = extract_routing_metrics(args.baseline)
        improved_metrics = extract_routing_metrics(args.improved)
        improved_metrics["improvement_id"] = args.improvement_id or "Unknown"

        comparison = compare_runs(baseline_metrics, improved_metrics)
        comparisons.append(comparison)

        # 同时输出 JSON
        print(json.dumps(comparison, indent=2))

    else:
        parser.print_help()
        return 1

    if comparisons:
        generate_report(comparisons, args.output)
        print(f"\nReport generated: {args.output}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
