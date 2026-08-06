#!/usr/bin/env python3
"""
完整物理设计流程运行器 + 详细报告生成器
运行完整的 floorplan -> routing -> GDS 流程，并生成详细的对比报告
"""

import os
import sys
import json
import subprocess
import shutil
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any
import argparse

# 添加 flows 目录到 Python 路径
sys.path.insert(0, str(Path(__file__).parent))
from flow_manager import FlowManager, FlowConfig
from tcl_generator import TCLGenerator

class CompleteFlowRunner:
    """完整流程运行器"""

    def __init__(self, benchmark_root: Path):
        self.benchmark_root = Path(benchmark_root)
        self.flow_manager = FlowManager(benchmark_root)
        self.results = {}

    def run_design_flow(self, design_name: str, output_dir: Optional[Path] = None) -> Dict[str, Any]:
        """运行单个设计的完整流程"""
        print(f"\n{'='*80}")
        print(f"开始运行设计: {design_name}")
        print(f"{'='*80}\n")

        # 加载配置
        config = self.flow_manager.load_design_config(design_name)

        # 设置输出目录
        if output_dir is None:
            output_dir = self.benchmark_root / "results" / f"flow_run_{datetime.now().strftime('%Y%m%d_%H%M%S')}" / design_name
        else:
            output_dir = output_dir / design_name

        output_dir.mkdir(parents=True, exist_ok=True)
        workspace_dir = output_dir / "workspace"
        workspace_dir.mkdir(exist_ok=True)

        # 生成 TCL 脚本
        print("📝 生成 TCL 脚本...")
        tcl_gen = TCLGenerator(config, workspace_dir)
        script_dir = workspace_dir / "script"
        script_dir.mkdir(parents=True, exist_ok=True)

        # 生成所有阶段的脚本
        stages = {
            'floorplan': tcl_gen.generate_floorplan_tcl,
            'fanout': tcl_gen.generate_fanout_tcl,
            'placement': tcl_gen.generate_placement_tcl,
            'cts': tcl_gen.generate_cts_tcl,
            'legalization': tcl_gen.generate_legalization_tcl,
            'routing': tcl_gen.generate_routing_tcl,
            'filler': tcl_gen.generate_filler_tcl,
        }

        stage_results = {}

        # 运行每个阶段
        for stage_name, gen_func in stages.items():
            print(f"\n{'─'*60}")
            print(f"🔧 阶段: {stage_name.upper()}")
            print(f"{'─'*60}")

            # 生成脚本
            tcl_script = gen_func()
            script_file = script_dir / f"{stage_name}.tcl"
            with open(script_file, 'w') as f:
                f.write(tcl_script)
            print(f"  ✓ 脚本已生成: {script_file}")

            # 运行 iEDA
            start_time = time.time()
            success, log_content = self._run_ieda(config.ieda_bin, script_file, workspace_dir)
            elapsed = time.time() - start_time

            if success:
                print(f"  ✓ {stage_name} 完成 ({elapsed:.1f}s)")
                stage_results[stage_name] = {
                    'status': 'success',
                    'runtime_s': elapsed,
                    'log': log_content
                }
            else:
                print(f"  ✗ {stage_name} 失败 ({elapsed:.1f}s)")
                stage_results[stage_name] = {
                    'status': 'failed',
                    'runtime_s': elapsed,
                    'log': log_content
                }
                # 阶段失败，停止后续流程
                break

        # 收集最终结果
        result_summary = self._collect_results(workspace_dir, stage_results, config)

        # 保存结果摘要
        summary_file = output_dir / "flow_summary.json"
        with open(summary_file, 'w') as f:
            json.dump(result_summary, f, indent=2)

        print(f"\n{'='*80}")
        print(f"流程完成: {design_name}")
        print(f"结果目录: {output_dir}")
        print(f"摘要文件: {summary_file}")
        print(f"{'='*80}\n")

        return result_summary

    def _run_ieda(self, ieda_bin: Path, script_file: Path, workspace_dir: Path) -> tuple[bool, str]:
        """运行 iEDA 命令"""
        if not ieda_bin.exists():
            print(f"  ✗ iEDA 二进制不存在: {ieda_bin}")
            return False, "iEDA binary not found"

        # 设置环境变量
        env = os.environ.copy()
        # 如果是 conda 环境，设置 LD_LIBRARY_PATH
        conda_prefix = env.get('CONDA_PREFIX', '')
        if conda_prefix:
            lib_path = f"{conda_prefix}/lib"
            if 'LD_LIBRARY_PATH' in env:
                env['LD_LIBRARY_PATH'] = f"{lib_path}:{env['LD_LIBRARY_PATH']}"
            else:
                env['LD_LIBRARY_PATH'] = lib_path

        # 运行命令
        cmd = [str(ieda_bin), "-script", str(script_file)]
        log_file = workspace_dir / f"{script_file.stem}.log"

        try:
            with open(log_file, 'w') as log:
                result = subprocess.run(
                    cmd,
                    cwd=workspace_dir,
                    stdout=log,
                    stderr=subprocess.STDOUT,
                    env=env,
                    timeout=3600  # 1小时超时
                )

            # 读取日志
            with open(log_file, 'r') as f:
                log_content = f.read()

            return result.returncode == 0, log_content

        except subprocess.TimeoutExpired:
            return False, "Timeout after 1 hour"
        except Exception as e:
            return False, f"Exception: {str(e)}"

    def _collect_results(self, workspace_dir: Path, stage_results: Dict, config: FlowConfig) -> Dict[str, Any]:
        """收集所有结果指标"""
        result_dir = workspace_dir / "result"

        summary = {
            'design': config.design_name,
            'pdk': config.pdk,
            'timestamp': datetime.now().isoformat(),
            'stages': stage_results,
            'metrics': {}
        }

        # 提取关键指标
        # 1. 面积和利用率
        if result_dir.exists():
            # 从最后的 DEF 文件提取
            def_files = list(result_dir.glob("**/*_result.def"))
            if def_files:
                last_def = max(def_files, key=lambda p: p.stat().st_mtime)
                summary['metrics']['final_def'] = str(last_def.relative_to(workspace_dir))

        # 2. 时序 (STA 报告)
        sta_reports = list(result_dir.glob("**/sta/*.rpt"))
        if sta_reports:
            summary['metrics']['sta_reports'] = [str(p.relative_to(workspace_dir)) for p in sta_reports]

        # 3. 功耗
        power_reports = list(result_dir.glob("**/power/*.rpt"))
        if power_reports:
            summary['metrics']['power_reports'] = [str(p.relative_to(workspace_dir)) for p in power_reports]

        # 4. DRC
        drc_reports = list(result_dir.glob("**/drc/*.rpt"))
        if drc_reports:
            summary['metrics']['drc_reports'] = [str(p.relative_to(workspace_dir)) for p in drc_reports]

        # 5. 线长
        wirelength_reports = list(result_dir.glob("**/wirelength.rpt"))
        if wirelength_reports:
            summary['metrics']['wirelength_reports'] = [str(p.relative_to(workspace_dir)) for p in wirelength_reports]

        # 6. GDS
        gds_files = list(result_dir.glob("**/*.gds"))
        if gds_files:
            summary['metrics']['gds_file'] = str(gds_files[0].relative_to(workspace_dir))

        return summary

    def generate_comparison_report(self, designs: List[str], output_file: Path):
        """生成详细对比报告"""
        print(f"\n{'='*80}")
        print(f"生成对比报告")
        print(f"{'='*80}\n")

        # 使用现有的报告生成脚本
        report_gen_script = self.benchmark_root / "flows" / "generate_comparison_report.py"
        if report_gen_script.exists():
            cmd = [
                sys.executable,
                str(report_gen_script),
                "--designs", *designs,
                "--output", str(output_file)
            ]
            try:
                subprocess.run(cmd, check=True)
                print(f"✓ 报告已生成: {output_file}")
            except subprocess.CalledProcessError as e:
                print(f"✗ 报告生成失败: {e}")
        else:
            print(f"✗ 报告生成脚本不存在: {report_gen_script}")

def main():
    parser = argparse.ArgumentParser(description='运行完整物理设计流程并生成报告')
    parser.add_argument('--designs', nargs='+', required=True,
                        help='要运行的设计名称列表')
    parser.add_argument('--output-dir', type=Path,
                        help='输出目录 (默认: benchmarks/results/flow_run_<timestamp>)')
    parser.add_argument('--report', type=Path,
                        help='报告输出文件 (默认: benchmarks/reports/comparison_<timestamp>.md)')
    parser.add_argument('--benchmark-root', type=Path,
                        default=Path(__file__).resolve().parents[1],
                        help='Benchmark 根目录')

    args = parser.parse_args()

    # 设置输出目录
    if args.output_dir is None:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        args.output_dir = args.benchmark_root / "results" / f"flow_run_{timestamp}"

    if args.report is None:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        args.report = args.benchmark_root / "reports" / f"comparison_{timestamp}.md"

    # 创建流程运行器
    runner = CompleteFlowRunner(args.benchmark_root)

    # 运行所有设计
    all_results = {}
    for design in args.designs:
        try:
            result = runner.run_design_flow(design, args.output_dir)
            all_results[design] = result
        except Exception as e:
            print(f"✗ 设计 {design} 运行失败: {e}")
            import traceback
            traceback.print_exc()
            all_results[design] = {'status': 'error', 'error': str(e)}

    # 保存汇总结果
    summary_file = args.output_dir / "all_results.json"
    with open(summary_file, 'w') as f:
        json.dump(all_results, f, indent=2)

    print(f"\n{'='*80}")
    print(f"所有流程完成")
    print(f"结果目录: {args.output_dir}")
    print(f"汇总文件: {summary_file}")
    print(f"{'='*80}\n")

    # 生成对比报告
    if len(args.designs) > 1:
        runner.generate_comparison_report(args.designs, args.report)

if __name__ == '__main__':
    main()
