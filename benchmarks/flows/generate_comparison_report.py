#!/usr/bin/env python3
"""
生成13个AES设计的对比分析报告
提取各阶段的DEF、GDS和报告文件，进行PPA对比分析
"""

import os
import sys
import json
import glob
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

# 13个选定的设计
DESIGNS = [
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
    "aes_core_sky130_a"
]

# 工艺库分类
PDK_MAP = {
    "sky130": ["aes_sky130_a", "aes_sky130_b", "aes_sky130_t", "aes_core_sky130_a"],
    "nangate45": ["aes_nangate45_a", "aes_nangate45_b", "aes_nangate45_t"],
    "asap7": ["aes_asap7_a", "aes_asap7_b", "aes_asap7_t"],
    "ics55": ["aes_ics55_a", "aes_ics55_b", "aes_ics55_t"]
}

# 流程阶段
STAGES = [
    "iFP",
    "iTO_fix_fanout",
    "iPL",
    "iCTS",
    "iTO_drv",
    "iTO_hold",
    "iPL_legalization",
    "iRT",
    "iRT_DRC"
]

class AESAnalyzer:
    def __init__(self, benchmark_dir: str):
        self.benchmark_dir = Path(benchmark_dir)
        self.designs_dir = self.benchmark_dir / "designs"
        self.report_dir = self.benchmark_dir / "reports"
        self.report_dir.mkdir(exist_ok=True)

        self.results = {}

    def analyze_design(self, design_name: str) -> Dict[str, Any]:
        """分析单个设计的运行结果"""
        design_dir = self.designs_dir / design_name
        workspace_dir = design_dir / "workspace"
        result_dir = workspace_dir / "result"

        if not result_dir.exists():
            return {
                "design": design_name,
                "status": "not_run",
                "error": "Result directory not found"
            }

        result = {
            "design": design_name,
            "status": "unknown",
            "stages": {},
            "files": {
                "def": [],
                "gds": [],
                "rpt": []
            },
            "metrics": {}
        }

        # 检查各阶段的DEF文件
        for stage in STAGES:
            def_file = result_dir / f"{stage}_result.def"
            if def_file.exists():
                result["stages"][stage] = "completed"
                result["files"]["def"].append(str(def_file))
                # 提取DEF文件信息
                metrics = self.extract_def_metrics(def_file)
                if metrics:
                    result["metrics"][stage] = metrics
            else:
                result["stages"][stage] = "missing"

        # 查找GDS文件
        gds_files = list(result_dir.glob("*.gds"))
        result["files"]["gds"] = [str(f) for f in gds_files]

        # 查找报告文件
        report_dir = result_dir / "report"
        if report_dir.exists():
            rpt_files = list(report_dir.rglob("*.rpt"))
            result["files"]["rpt"] = [str(f) for f in rpt_files]

            # 提取时序报告
            timing_metrics = self.extract_timing_metrics(report_dir)
            if timing_metrics:
                result["metrics"]["timing"] = timing_metrics

        # 查找日志文件分析错误
        log_files = list(result_dir.glob("*.log"))
        errors = self.analyze_logs(log_files)
        if errors:
            result["errors"] = errors
            result["status"] = "failed"
        else:
            # 判断是否成功完成
            if result["stages"].get("iRT_DRC") == "completed":
                result["status"] = "success"
            elif result["stages"].get("iPL") == "completed":
                result["status"] = "partial"
            else:
                result["status"] = "failed"

        return result

    def extract_def_metrics(self, def_file: Path) -> Optional[Dict[str, Any]]:
        """从DEF文件提取指标"""
        try:
            with open(def_file, 'r') as f:
                content = f.read()

            metrics = {}

            # 提取芯片面积
            die_area_match = re.search(r'DIEAREA\s+\(\s*(\d+)\s+(\d+)\s*\)\s+\(\s*(\d+)\s+(\d+)\s*\)', content)
            if die_area_match:
                x1, y1, x2, y2 = map(int, die_area_match.groups())
                width = x2 - x1
                height = y2 - y1
                area = width * height
                metrics["die_area"] = area
                metrics["die_width"] = width
                metrics["die_height"] = height

            # 提取单元数量
            components_match = re.search(r'COMPONENTS\s+(\d+)', content)
            if components_match:
                metrics["num_components"] = int(components_match.group(1))

            # 提取网络数量
            nets_match = re.search(r'NETS\s+(\d+)', content)
            if nets_match:
                metrics["num_nets"] = int(nets_match.group(1))

            return metrics if metrics else None
        except Exception as e:
            print(f"Error parsing DEF file {def_file}: {e}")
            return None

    def extract_timing_metrics(self, report_dir: Path) -> Optional[Dict[str, Any]]:
        """从时序报告提取指标"""
        metrics = {}

        # 查找STA报告
        sta_reports = list(report_dir.rglob("*sta*.rpt"))
        for rpt_file in sta_reports:
            try:
                with open(rpt_file, 'r') as f:
                    content = f.read()

                # 提取WNS (Worst Negative Slack)
                wns_match = re.search(r'WNS[:\s]+([+-]?\d+\.?\d*)', content)
                if wns_match:
                    metrics["wns"] = float(wns_match.group(1))

                # 提取TNS (Total Negative Slack)
                tns_match = re.search(r'TNS[:\s]+([+-]?\d+\.?\d*)', content)
                if tns_match:
                    metrics["tns"] = float(tns_match.group(1))

            except Exception as e:
                print(f"Error parsing timing report {rpt_file}: {e}")

        return metrics if metrics else None

    def analyze_logs(self, log_files: List[Path]) -> List[str]:
        """分析日志文件中的错误"""
        errors = []

        for log_file in log_files:
            try:
                with open(log_file, 'r') as f:
                    content = f.read()

                # 查找错误信息
                error_patterns = [
                    r'Error\s*:(.+?)(?:\n|$)',
                    r'SIGFPE',
                    r'Segmentation fault',
                    r'core dumped'
                ]

                for pattern in error_patterns:
                    matches = re.finditer(pattern, content, re.IGNORECASE)
                    for match in matches:
                        errors.append(match.group(0).strip())

            except Exception as e:
                print(f"Error reading log file {log_file}: {e}")

        return errors

    def analyze_all_designs(self):
        """分析所有13个设计"""
        print("开始分析13个AES设计...")

        for design in DESIGNS:
            print(f"  分析 {design}...")
            result = self.analyze_design(design)
            self.results[design] = result

        print(f"分析完成! 共处理 {len(self.results)} 个设计")

    def generate_json_report(self) -> str:
        """生成JSON格式报告"""
        report_file = self.report_dir / f"comparison_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)

        print(f"JSON报告已生成: {report_file}")
        return str(report_file)

    def generate_markdown_report(self) -> str:
        """生成Markdown格式的对比分析报告"""
        report_file = self.report_dir / f"comparison_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"

        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# 13个AES设计对比分析报告\n\n")
            f.write(f"**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

            # 1. 总体统计
            f.write("## 1. 总体统计\n\n")

            status_count = {"success": 0, "partial": 0, "failed": 0, "not_run": 0}
            for design, result in self.results.items():
                status = result.get("status", "unknown")
                status_count[status] = status_count.get(status, 0) + 1

            f.write(f"- 总设计数: {len(self.results)}\n")
            f.write(f"- 完全成功: {status_count['success']}\n")
            f.write(f"- 部分完成: {status_count['partial']}\n")
            f.write(f"- 失败: {status_count['failed']}\n")
            f.write(f"- 未运行: {status_count['not_run']}\n\n")

            # 2. 按工艺库分类统计
            f.write("## 2. 按工艺库分类\n\n")

            for pdk, designs in PDK_MAP.items():
                f.write(f"### {pdk.upper()}\n\n")
                f.write("| 设计名称 | 状态 | 完成阶段 | 芯片面积 | 单元数 | 网络数 |\n")
                f.write("|---------|------|---------|---------|--------|--------|\n")

                for design in designs:
                    if design not in self.results:
                        continue

                    result = self.results[design]
                    status = result.get("status", "unknown")

                    # 计算完成的阶段数
                    completed_stages = sum(1 for s, st in result.get("stages", {}).items() if st == "completed")
                    total_stages = len(STAGES)

                    # 获取最新的指标（通常是最后一个阶段）
                    metrics = {}
                    for stage in reversed(STAGES):
                        if stage in result.get("metrics", {}):
                            metrics = result["metrics"][stage]
                            break

                    area = metrics.get("die_area", "N/A")
                    if isinstance(area, int):
                        area = f"{area:,}"

                    components = metrics.get("num_components", "N/A")
                    if isinstance(components, int):
                        components = f"{components:,}"

                    nets = metrics.get("num_nets", "N/A")
                    if isinstance(nets, int):
                        nets = f"{nets:,}"

                    f.write(f"| {design} | {status} | {completed_stages}/{total_stages} | {area} | {components} | {nets} |\n")

                f.write("\n")

            # 3. 各阶段完成情况
            f.write("## 3. 流程各阶段完成情况\n\n")
            f.write("| 设计名称 | " + " | ".join(STAGES) + " |\n")
            f.write("|---------|" + "|".join(["---"] * len(STAGES)) + "|\n")

            for design in DESIGNS:
                if design not in self.results:
                    continue

                result = self.results[design]
                stages = result.get("stages", {})

                row = [design]
                for stage in STAGES:
                    status = stages.get(stage, "missing")
                    symbol = "✓" if status == "completed" else "✗"
                    row.append(symbol)

                f.write("| " + " | ".join(row) + " |\n")

            f.write("\n")

            # 4. 失败设计详细信息
            failed_designs = [(d, r) for d, r in self.results.items() if r.get("status") in ["failed", "partial"]]
            if failed_designs:
                f.write("## 4. 失败/部分完成设计详情\n\n")

                for design, result in failed_designs:
                    f.write(f"### {design}\n\n")
                    f.write(f"- **状态**: {result.get('status')}\n")

                    if "errors" in result and result["errors"]:
                        f.write(f"- **错误信息**:\n")
                        for error in result["errors"][:5]:  # 最多显示5个错误
                            f.write(f"  - `{error}`\n")

                    f.write("\n")

            # 5. 文件清单
            f.write("## 5. 生成的文件\n\n")

            for design in DESIGNS:
                if design not in self.results:
                    continue

                result = self.results[design]
                files = result.get("files", {})

                if any(files.values()):
                    f.write(f"### {design}\n\n")

                    if files.get("def"):
                        f.write(f"- **DEF文件**: {len(files['def'])} 个\n")

                    if files.get("gds"):
                        f.write(f"- **GDS文件**: {len(files['gds'])} 个\n")

                    if files.get("rpt"):
                        f.write(f"- **报告文件**: {len(files['rpt'])} 个\n")

                    f.write("\n")

            # 6. 总结和建议
            f.write("## 6. 总结和建议\n\n")

            if status_count["success"] == len(self.results):
                f.write("✓ 所有设计均成功完成全部流程！\n\n")
            elif status_count["failed"] > 0 or status_count["partial"] > 0:
                f.write("需要关注的问题:\n\n")

                if status_count["not_run"] > 0:
                    f.write(f"- {status_count['not_run']} 个设计未运行\n")

                if status_count["failed"] > 0:
                    f.write(f"- {status_count['failed']} 个设计运行失败，需要检查错误日志\n")

                if status_count["partial"] > 0:
                    f.write(f"- {status_count['partial']} 个设计部分完成，可能在某个阶段卡住\n")

            f.write("\n---\n\n")
            f.write(f"报告生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        print(f"Markdown报告已生成: {report_file}")
        return str(report_file)

def main():
    # 获取benchmark目录
    script_dir = Path(__file__).parent
    benchmark_dir = script_dir.parent

    print(f"Benchmark目录: {benchmark_dir}")

    # 创建分析器
    analyzer = AESAnalyzer(str(benchmark_dir))

    # 分析所有设计
    analyzer.analyze_all_designs()

    # 生成报告
    json_file = analyzer.generate_json_report()
    md_file = analyzer.generate_markdown_report()

    print("\n" + "="*60)
    print("报告生成完成!")
    print(f"  JSON报告: {json_file}")
    print(f"  Markdown报告: {md_file}")
    print("="*60)

if __name__ == "__main__":
    main()
