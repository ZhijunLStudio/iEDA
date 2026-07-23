#!/usr/bin/env python3
"""
生成AES设计的完整阶段报告
提取每个阶段的关键指标和结果
"""

import re
import json
from pathlib import Path
from datetime import datetime

class StageReportGenerator:
    def __init__(self, design_path):
        self.design_path = Path(design_path)
        self.result_dir = self.design_path / "workspace" / "result"
        self.report_dir = self.result_dir / "report"
        self.stages = {}

    def extract_floorplan_results(self):
        """提取Floorplan阶段结果"""
        rpt_file = self.report_dir / "fp_db.rpt"
        if not rpt_file.exists():
            return None

        with open(rpt_file, 'r') as f:
            content = f.read()

        results = {
            "stage": "Floorplan (iFP)",
            "status": "Completed",
            "metrics": {}
        }

        # 提取芯片面积
        area_match = re.search(r'DIE Area.*?=\s*([\d.]+)\s*\*\s*([\d.]+)', content)
        if area_match:
            width, height = float(area_match.group(1)), float(area_match.group(2))
            results["metrics"]["die_area_um2"] = width * height
            results["metrics"]["die_width_um"] = width
            results["metrics"]["die_height_um"] = height

        # 提取实例数量
        inst_match = re.search(r'Number - Instance\s*\|\s*(\d+)', content)
        if inst_match:
            results["metrics"]["total_instances"] = int(inst_match.group(1))

        # 提取逻辑单元数量
        logic_match = re.search(r'Core - logic\s*\|\s*(\d+)', content)
        if logic_match:
            results["metrics"]["logic_instances"] = int(logic_match.group(1))

        return results

    def extract_placement_results(self):
        """提取Placement阶段结果"""
        rpt_file = self.report_dir / "pl_db.rpt"
        if not rpt_file.exists():
            return None

        with open(rpt_file, 'r') as f:
            content = f.read()

        results = {
            "stage": "Placement (iPL)",
            "status": "Completed",
            "metrics": {}
        }

        # 提取实例数量
        inst_match = re.search(r'Number - Instance\s*\|\s*(\d+)', content)
        if inst_match:
            results["metrics"]["total_instances"] = int(inst_match.group(1))

        # 提取网络数量
        net_match = re.search(r'Number - Net\s*\|\s*(\d+)', content)
        if net_match:
            results["metrics"]["total_nets"] = int(net_match.group(1))

        # 提取利用率
        usage_match = re.search(r'DIE Usage\s*\|\s*([\d.]+)', content)
        if usage_match:
            results["metrics"]["die_usage"] = float(usage_match.group(1))

        return results

    def extract_cts_results(self):
        """提取Clock Tree阶段结果"""
        log_file = self.result_dir / "iCTS.log"
        if not log_file.exists():
            return None

        with open(log_file, 'r') as f:
            content = f.read()

        results = {
            "stage": "Clock Tree Synthesis (iCTS)",
            "status": "Completed",
            "metrics": {}
        }

        # 提取CTS关键指标
        metrics_map = {
            "sink_count": r'sink_count\s*\|\s*(\d+)',
            "buffer_count": r'final_clock_buffer_count\s*\|\s*(\d+)',
            "buffer_area_um2": r'final_buffer_area\s*\|\s*([\d.]+)',
            "total_wirelength_um": r'total_clock_network_wirelength\s*\|\s*([\d.]+)',
            "max_wirelength_um": r'max_clock_net_wirelength\s*\|\s*([\d.]+)',
            "elapsed_time_s": r'elapsed_time\s*\|\s*([\d.]+)'
        }

        for key, pattern in metrics_map.items():
            match = re.search(pattern, content)
            if match:
                value = match.group(1)
                results["metrics"][key] = float(value) if '.' in value else int(value)

        return results

    def extract_timing_opt_results(self):
        """提取Timing Optimization阶段结果"""
        results = []

        # DRV优化
        drv_rpt = self.report_dir / "drv_db.rpt"
        if drv_rpt.exists():
            with open(drv_rpt, 'r') as f:
                content = f.read()

            drv_result = {
                "stage": "Timing Optimization - Drive (iTO)",
                "status": "Completed",
                "metrics": {}
            }

            inst_match = re.search(r'Number - Instance\s*\|\s*(\d+)', content)
            if inst_match:
                drv_result["metrics"]["total_instances"] = int(inst_match.group(1))

            results.append(drv_result)

        # Hold修复
        hold_rpt = self.report_dir / "hold_db.rpt"
        if hold_rpt.exists():
            with open(hold_rpt, 'r') as f:
                content = f.read()

            hold_result = {
                "stage": "Timing Optimization - Hold (iTO)",
                "status": "Completed",
                "metrics": {}
            }

            inst_match = re.search(r'Number - Instance\s*\|\s*(\d+)', content)
            if inst_match:
                hold_result["metrics"]["total_instances"] = int(inst_match.group(1))

            results.append(hold_result)

        return results

    def extract_legalization_results(self):
        """提取Legalization阶段结果"""
        rpt_file = self.report_dir / "lg_db.rpt"
        if not rpt_file.exists():
            return None

        with open(rpt_file, 'r') as f:
            content = f.read()

        results = {
            "stage": "Legalization (iPL)",
            "status": "Completed",
            "metrics": {}
        }

        inst_match = re.search(r'Number - Instance\s*\|\s*(\d+)', content)
        if inst_match:
            results["metrics"]["total_instances"] = int(inst_match.group(1))

        return results

    def extract_routing_results(self):
        """提取Routing阶段结果"""
        log_file = self.result_dir / "iRT.log"
        if not log_file.exists():
            return None

        with open(log_file, 'r') as f:
            content = f.read()

        results = {
            "stage": "Routing (iRT)",
            "status": "In Progress / Completed",
            "metrics": {}
        }

        # 提取布线统计
        # 总线长
        wire_match = re.search(r'Total.*?wire_length.*?([\d.e+]+)', content)
        if wire_match:
            results["metrics"]["total_wirelength"] = float(wire_match.group(1))

        # 总通孔数
        via_match = re.search(r'Total\s*\|\s*(\d+)\s*\|\s*100\.00%', content)
        if via_match:
            results["metrics"]["total_vias"] = int(via_match.group(1))

        # 提取violations
        viol_matches = re.findall(r'(\d+)\s+violations', content)
        if viol_matches:
            results["metrics"]["violations"] = int(viol_matches[-1])

        return results

    def generate_report(self):
        """生成完整报告"""
        print("提取各阶段结果...")

        # 收集所有阶段
        self.stages["floorplan"] = self.extract_floorplan_results()
        self.stages["placement"] = self.extract_placement_results()
        self.stages["cts"] = self.extract_cts_results()

        timing_opts = self.extract_timing_opt_results()
        if timing_opts:
            self.stages["timing_opt_drv"] = timing_opts[0] if len(timing_opts) > 0 else None
            self.stages["timing_opt_hold"] = timing_opts[1] if len(timing_opts) > 1 else None

        self.stages["legalization"] = self.extract_legalization_results()
        self.stages["routing"] = self.extract_routing_results()

        return self.stages

    def generate_markdown_report(self, output_file):
        """生成Markdown格式报告"""
        stages_data = self.generate_report()

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# AES设计完整阶段报告\n\n")
            f.write(f"**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"**设计**: {self.design_path.name}\n\n")
            f.write("---\n\n")

            # 总览
            f.write("## 流程总览\n\n")
            f.write("| 阶段 | 状态 | 输出文件 |\n")
            f.write("|------|------|----------|\n")

            stage_order = [
                ("floorplan", "iFP_result.def"),
                ("placement", "iPL_result.def"),
                ("cts", "iCTS_result.def"),
                ("timing_opt_drv", "iTO_drv_result.def"),
                ("timing_opt_hold", "iTO_hold_result.def"),
                ("legalization", "iPL_lg_result.def"),
                ("routing", "iRT_result.def")
            ]

            for stage_key, def_file in stage_order:
                stage = stages_data.get(stage_key)
                if stage:
                    status_icon = "✅" if stage["status"] == "Completed" else "🔄"
                    def_path = self.result_dir / def_file
                    has_file = "✓" if def_path.exists() else "✗"
                    f.write(f"| {stage['stage']} | {status_icon} {stage['status']} | {has_file} {def_file} |\n")

            f.write("\n---\n\n")

            # 详细结果
            f.write("## 各阶段详细结果\n\n")

            for stage_key, _ in stage_order:
                stage = stages_data.get(stage_key)
                if not stage:
                    continue

                f.write(f"### {stage['stage']}\n\n")
                f.write(f"**状态**: {stage['status']}\n\n")

                if stage.get("metrics"):
                    f.write("**关键指标**:\n\n")
                    for key, value in stage["metrics"].items():
                        # 格式化显示
                        if isinstance(value, float):
                            if value > 1000:
                                formatted = f"{value:,.2f}"
                            else:
                                formatted = f"{value:.2f}"
                        elif isinstance(value, int):
                            formatted = f"{value:,}"
                        else:
                            formatted = str(value)

                        # 友好的名称
                        friendly_name = key.replace('_', ' ').title()
                        f.write(f"- **{friendly_name}**: {formatted}\n")

                f.write("\n")

            f.write("---\n\n")
            f.write(f"*报告生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n")

        print(f"✓ Markdown报告已生成: {output_file}")

    def generate_json_report(self, output_file):
        """生成JSON格式报告"""
        stages_data = self.generate_report()

        report = {
            "design": self.design_path.name,
            "timestamp": datetime.now().isoformat(),
            "stages": stages_data
        }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        print(f"✓ JSON报告已生成: {output_file}")

def main():
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 generate_stage_report.py <design_path>")
        print("Example: python3 generate_stage_report.py /path/to/benchmarks/designs/aes_sky130_a")
        sys.exit(1)

    design_path = sys.argv[1]
    generator = StageReportGenerator(design_path)

    # 生成报告
    output_md = Path(design_path) / "workspace" / "result" / "stage_report.md"
    output_json = Path(design_path) / "workspace" / "result" / "stage_report.json"

    generator.generate_markdown_report(output_md)
    generator.generate_json_report(output_json)

    print("\n报告生成完成！")

if __name__ == "__main__":
    main()
