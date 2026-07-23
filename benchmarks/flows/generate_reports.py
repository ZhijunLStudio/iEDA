#!/usr/bin/env python3
"""
生成完整的设计报告 - 汇总时序、功耗、IR、DRC、拥塞等信息
"""

import json
from pathlib import Path
from typing import Dict, List
import re

class ReportGenerator:
    """报告生成器"""
    
    @staticmethod
    def parse_timing_report(result_dir: Path) -> Dict:
        """解析时序报告"""
        timing_data = {
            "wns": None,
            "tns": None,
            "setup_violations": 0,
            "hold_violations": 0
        }
        
        # 查找时序报告文件
        for rpt_file in result_dir.glob("*sta*.rpt"):
            try:
                content = rpt_file.read_text()
                
                # 解析 WNS
                wns_match = re.search(r'WNS[:\s]+(-?\d+\.?\d*)', content, re.IGNORECASE)
                if wns_match:
                    timing_data["wns"] = float(wns_match.group(1))
                
                # 解析 TNS
                tns_match = re.search(r'TNS[:\s]+(-?\d+\.?\d*)', content, re.IGNORECASE)
                if tns_match:
                    timing_data["tns"] = float(tns_match.group(1))
                
            except Exception as e:
                print(f"  解析 {rpt_file.name} 失败: {e}")
        
        return timing_data
    
    @staticmethod
    def parse_power_report(result_dir: Path) -> Dict:
        """解析功耗报告"""
        power_data = {
            "total_power": None,
            "dynamic_power": None,
            "leakage_power": None,
            "unit": "mW"
        }
        
        for rpt_file in result_dir.glob("*power*.rpt"):
            try:
                content = rpt_file.read_text()
                
                # 解析功耗数据
                total_match = re.search(r'Total[:\s]+(\d+\.?\d*)\s*(\w+)', content, re.IGNORECASE)
                if total_match:
                    power_data["total_power"] = float(total_match.group(1))
                    power_data["unit"] = total_match.group(2)
                
            except Exception as e:
                print(f"  解析 {rpt_file.name} 失败: {e}")
        
        return power_data
    
    @staticmethod
    def parse_drc_report(result_dir: Path) -> Dict:
        """解析 DRC 报告"""
        drc_data = {
            "total_violations": 0,
            "by_type": {}
        }
        
        for rpt_file in result_dir.glob("*drc*.rpt"):
            try:
                content = rpt_file.read_text()
                
                # 解析 DRC 违例数
                total_match = re.search(r'Total[:\s]+(\d+)', content, re.IGNORECASE)
                if total_match:
                    drc_data["total_violations"] = int(total_match.group(1))
                
            except Exception as e:
                print(f"  解析 {rpt_file.name} 失败: {e}")
        
        return drc_data
    
    @staticmethod
    def parse_congestion_report(result_dir: Path) -> Dict:
        """解析拥塞报告"""
        congestion_data = {
            "max_overflow": None,
            "avg_overflow": None
        }
        
        for rpt_file in result_dir.glob("*congestion*.rpt"):
            try:
                content = rpt_file.read_text()
                
                # 解析拥塞数据
                max_match = re.search(r'Max[:\s]+(\d+\.?\d*)', content, re.IGNORECASE)
                if max_match:
                    congestion_data["max_overflow"] = float(max_match.group(1))
                
            except Exception as e:
                print(f"  解析 {rpt_file.name} 失败: {e}")
        
        return congestion_data
    
    @staticmethod
    def generate_summary(design_name: str, result_dir: Path) -> Dict:
        """生成设计汇总报告"""
        print(f"\n生成报告: {design_name}")
        
        summary = {
            "design": design_name,
            "result_dir": str(result_dir),
            "timing": ReportGenerator.parse_timing_report(result_dir),
            "power": ReportGenerator.parse_power_report(result_dir),
            "drc": ReportGenerator.parse_drc_report(result_dir),
            "congestion": ReportGenerator.parse_congestion_report(result_dir),
            "files": {
                "def_files": [],
                "gds_files": [],
                "reports": []
            }
        }
        
        # 收集文件列表
        summary["files"]["def_files"] = [str(f.name) for f in result_dir.glob("*.def")]
        summary["files"]["gds_files"] = [str(f.name) for f in result_dir.glob("*.gds")]
        summary["files"]["reports"] = [str(f.name) for f in result_dir.glob("*.rpt")]
        
        return summary
    
    @staticmethod
    def generate_markdown_report(summary: Dict, output_file: Path):
        """生成 Markdown 格式报告"""
        md = f"""# 设计报告：{summary['design']}

## 时序分析

- **WNS**: {summary['timing']['wns']} ns
- **TNS**: {summary['timing']['tns']} ns
- **Setup Violations**: {summary['timing']['setup_violations']}
- **Hold Violations**: {summary['timing']['hold_violations']}

## 功耗分析

- **Total Power**: {summary['power']['total_power']} {summary['power']['unit']}
- **Dynamic Power**: {summary['power']['dynamic_power']} {summary['power']['unit']}
- **Leakage Power**: {summary['power']['leakage_power']} {summary['power']['unit']}

## DRC 检查

- **Total Violations**: {summary['drc']['total_violations']}

## 拥塞分析

- **Max Overflow**: {summary['congestion']['max_overflow']}
- **Avg Overflow**: {summary['congestion']['avg_overflow']}

## 生成的文件

### DEF 文件
{chr(10).join(f'- {f}' for f in summary['files']['def_files']) or '- (无)'}

### GDS 文件
{chr(10).join(f'- {f}' for f in summary['files']['gds_files']) or '- (无)'}

### 报告文件
{chr(10).join(f'- {f}' for f in summary['files']['reports']) or '- (无)'}

---
生成时间: {summary.get('timestamp', 'N/A')}
"""
        
        output_file.write_text(md)
        print(f"  ✓ Markdown 报告: {output_file}")

if __name__ == "__main__":
    import sys
    from datetime import datetime
    
    if len(sys.argv) < 2:
        print("用法: python3 generate_reports.py <design_name>")
        sys.exit(1)
    
    design_name = sys.argv[1]
    benchmark_root = Path("/home/lxq/AiEDA/iEDA.ai/benchmarks")
    result_dir = benchmark_root / "designs" / design_name / "workspace" / "result"
    
    if not result_dir.exists():
        print(f"错误: 结果目录不存在: {result_dir}")
        sys.exit(1)
    
    # 生成报告
    summary = ReportGenerator.generate_summary(design_name, result_dir)
    summary["timestamp"] = datetime.now().isoformat()
    
    # 保存 JSON
    json_file = result_dir / "summary_report.json"
    with open(json_file, 'w') as f:
        json.dump(summary, f, indent=2)
    print(f"  ✓ JSON 报告: {json_file}")
    
    # 保存 Markdown
    md_file = result_dir / "summary_report.md"
    ReportGenerator.generate_markdown_report(summary, md_file)
    
    print("\n报告生成完成!")
