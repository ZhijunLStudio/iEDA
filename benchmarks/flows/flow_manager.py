#!/usr/bin/env python3
"""
iEDA.ai Flow Manager v2 - 集成 TCL 生成器
"""

import os
import sys
import json
import subprocess
import shutil
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List, Optional
import time

# 导入 TCL 生成器
sys.path.insert(0, str(Path(__file__).parent))
from tcl_generator import TCLGenerator

@dataclass
class FlowConfig:
    """流程配置"""
    design_name: str
    design_dir: Path
    pdk: str
    strategy: str
    top_module: str
    netlist: Path
    sdc: Path
    tech_lef: Path
    cells_lef: Path
    lib: Path
    die_area: str
    core_area: str
    core_util: float
    clock_period_ns: float
    clock_port: str
    foundry_root: Path
    result_dir: Path
    ieda_bin: Path

class FlowManager:
    """流程管理器"""
    
    def __init__(self, benchmark_root: Path):
        self.benchmark_root = Path(benchmark_root)
        self.flows_dir = self.benchmark_root / "flows"
        self.designs_dir = self.benchmark_root / "designs"
        self.pdk_root = Path("/home/lxq/AiEDA/Foundary")
        self.ieda_bin = Path("/home/lxq/AiEDA/iEDA.ai/bin/iEDA")
        
        # 检查 iEDA 二进制
        if not self.ieda_bin.exists():
            print(f"警告: iEDA binary not found: {self.ieda_bin}")
            print("需要先编译 iEDA")
    
    def load_design_config(self, design_name: str) -> FlowConfig:
        """加载设计配置"""
        design_dir = self.designs_dir / design_name
        config_file = design_dir / "design.json"
        
        if not config_file.exists():
            raise FileNotFoundError(f"Design config not found: {config_file}")
        
        with open(config_file) as f:
            config = json.load(f)
        
        # 解析路径（替换 $PDK）
        pdk = config['pdk']
        pdk_dir = self.pdk_root / pdk
        
        def resolve_path(path_str: str) -> Path:
            return Path(path_str.replace("$PDK", str(pdk_dir)))
        
        # 构建配置
        flow_config = FlowConfig(
            design_name=design_name,
            design_dir=design_dir,
            pdk=pdk,
            strategy=config.get('strategy', 'a'),
            top_module=config['top'],
            netlist=design_dir / config['inputs']['netlist'],
            sdc=design_dir / config['inputs']['sdc'],
            tech_lef=resolve_path(config['inputs']['tech_lef']),
            cells_lef=resolve_path(config['inputs']['cells_lef']),
            lib=resolve_path(config['inputs']['lib']),
            die_area=config['floorplan']['die_area'],
            core_area=config['floorplan']['core_area'],
            core_util=config['floorplan']['core_utilization'],
            clock_period_ns=config['clocks'][0]['period_ns'],
            clock_port=config['clocks'][0]['port'],
            foundry_root=self.pdk_root,
            result_dir=design_dir / "results",
            ieda_bin=self.ieda_bin
        )
        
        return flow_config
    
    def setup_workspace(self, config: FlowConfig) -> Path:
        """设置工作空间"""
        workspace = config.design_dir / "workspace"
        workspace.mkdir(exist_ok=True)
        
        # 创建目录结构
        (workspace / "script").mkdir(exist_ok=True)
        (workspace / "iEDA_config").mkdir(exist_ok=True)
        config.result_dir.mkdir(exist_ok=True)
        
        return workspace
    
    def generate_tcl_scripts(self, config: FlowConfig, workspace: Path):
        """生成 TCL 脚本 - 使用 TCLGenerator"""
        script_dir = workspace / "script"
        
        print("  生成 TCL 脚本...")
        TCLGenerator.gen_db_init_lef(script_dir)
        TCLGenerator.gen_db_path_setting(script_dir)
        TCLGenerator.gen_ifp_script(config, script_dir)
        TCLGenerator.gen_ipl_script(config, script_dir)
        TCLGenerator.gen_icts_script(config, script_dir)
        TCLGenerator.gen_irt_script(config, script_dir)
        TCLGenerator.gen_ito_script(config, script_dir)
        TCLGenerator.gen_ista_script(config, script_dir)
        TCLGenerator.gen_ipw_script(config, script_dir)
        TCLGenerator.gen_idrc_script(config, script_dir)
        TCLGenerator.gen_gds_script(config, script_dir)
        print("  ✓ TCL 脚本生成完成")
    
    def generate_config_files(self, config: FlowConfig, workspace: Path):
        """生成配置文件"""
        config_dir = workspace / "iEDA_config"
        
        print("  生成配置文件...")
        
        # flow_config.json
        flow_config = {
            "tech_lef_path": str(config.tech_lef),
            "lef_paths": [str(config.cells_lef)],
            "lib_paths": [str(config.lib)]
        }
        
        with open(config_dir / "flow_config.json", 'w') as f:
            json.dump(flow_config, f, indent=2)
        
        # db_default_config.json
        db_config = {
            "tech_lef": [str(config.tech_lef)],
            "lef": [str(config.cells_lef)],
            "def": [],
            "lib": [str(config.lib)]
        }
        
        with open(config_dir / "db_default_config.json", 'w') as f:
            json.dump(db_config, f, indent=2)
        
        # cts_default_config.json (如果需要)
        cts_config = {
            "root_buffer": "BUF_X1",
            "max_buf_tran": 0.5,
            "max_sink_tran": 0.5,
            "max_cap": 0.2,
            "max_fanout": 30,
            "max_length": 500
        }
        
        with open(config_dir / "cts_default_config.json", 'w') as f:
            json.dump(cts_config, f, indent=2)
        
        print("  ✓ 配置文件生成完成")
    
    def run_flow(self, config: FlowConfig, dry_run: bool = False) -> Dict:
        """运行完整流程"""
        print(f"\n{'='*60}")
        print(f"运行设计: {config.design_name}")
        print(f"PDK: {config.pdk}, 策略: {config.strategy}")
        print(f"Top: {config.top_module}")
        print(f"{'='*60}\n")
        
        workspace = self.setup_workspace(config)
        self.generate_config_files(config, workspace)
        self.generate_tcl_scripts(config, workspace)
        
        if dry_run:
            print("\n[DRY RUN] 仅生成脚本，不实际运行")
            return {"design": config.design_name, "dry_run": True}
        
        # 切换到工作目录
        original_dir = os.getcwd()
        os.chdir(workspace)
        
        # 设置环境变量
        env = os.environ.copy()
        env.update({
            "WORKSPACE": str(workspace),
            "CONFIG_DIR": str(workspace / "iEDA_config"),
            "FOUNDRY_DIR": str(self.pdk_root / config.pdk),
            "RESULT_DIR": str(config.result_dir),
            "TCL_SCRIPT_DIR": str(workspace / "script"),
            "DESIGN_TOP": config.top_module,
            "NETLIST_FILE": str(config.netlist),
            "SDC_FILE": str(config.sdc),
            "DIE_AREA": config.die_area,
            "CORE_AREA": config.core_area,
            "TECH_LEF_PATH": str(config.tech_lef),
            "CELLS_LEF_PATH": str(config.cells_lef),
            "LD_LIBRARY_PATH": "/home/lxq/AiEDA/micromamba/envs/ieda-build/lib"
        })
        
        results = {
            "design": config.design_name,
            "pdk": config.pdk,
            "strategy": config.strategy,
            "stages": {},
            "workspace": str(workspace)
        }
        
        # 运行各阶段
        stages = [
            ("iFP", "iFP_script/run_iFP.tcl", "Floorplan"),
            ("iPL", "iPL_script/run_iPL.tcl", "Placement"),
            ("iCTS", "iCTS_script/run_iCTS.tcl", "Clock Tree Synthesis"),
            ("iRT", "iRT_script/run_iRT.tcl", "Routing"),
            ("iTO", "iTO_script/run_iTO.tcl", "Timing Optimization"),
            ("iSTA", "iSTA_script/run_iSTA.tcl", "Static Timing Analysis"),
            ("iPW", "iPW_script/run_iPW.tcl", "Power Analysis"),
            ("iDRC", "iDRC_script/run_iDRC.tcl", "DRC Check"),
            ("GDS", "DB_script/run_def_to_gds.tcl", "GDS Generation")
        ]
        
        for stage_name, script_path, desc in stages:
            print(f"\n>>> 运行阶段: {desc} ({stage_name})")
            start_time = time.time()
            
            success, log = self._run_tcl_script(config, script_path, env)
            elapsed = time.time() - start_time
            
            results["stages"][stage_name] = {
                "success": success,
                "elapsed_sec": elapsed,
                "log_file": f"{stage_name}.log"
            }
            
            # 保存日志
            log_file = config.result_dir / f"{stage_name}.log"
            with open(log_file, 'w') as f:
                f.write(log)
            
            if not success:
                print(f"✗ 阶段 {stage_name} 失败 (见 {log_file})")
                results["failed_stage"] = stage_name
                break
            else:
                print(f"✓ 阶段 {stage_name} 完成 ({elapsed:.1f}s)")
        
        # 恢复目录
        os.chdir(original_dir)
        
        # 生成报告
        self.generate_reports(config, results)
        
        return results
    
    def _run_tcl_script(self, config: FlowConfig, script_path: str, env: Dict) -> tuple:
        """运行 TCL 脚本"""
        cmd = [str(config.ieda_bin), "-script", script_path]
        
        try:
            result = subprocess.run(
                cmd,
                env=env,
                capture_output=True,
                text=True,
                timeout=3600  # 1 hour timeout
            )
            return (result.returncode == 0, result.stdout + "\n" + result.stderr)
        except subprocess.TimeoutExpired:
            return (False, "Error: Command timeout (1 hour)")
        except Exception as e:
            return (False, f"Error: {str(e)}")
    
    def generate_reports(self, config: FlowConfig, results: Dict):
        """生成汇总报告"""
        report_file = config.result_dir / "flow_report.json"
        with open(report_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        print(f"\n✓ 报告已保存: {report_file}")

if __name__ == "__main__":
    manager = FlowManager(Path("/home/lxq/AiEDA/iEDA.ai/benchmarks"))
    
    # 测试单个设计
    if len(sys.argv) > 1:
        design_name = sys.argv[1]
    else:
        design_name = "aes_sky130_a"
    
    print(f"测试设计: {design_name}")
    config = manager.load_design_config(design_name)
    results = manager.run_flow(config, dry_run=True)
    
    print("\n配置加载成功!")
    print(f"  Top: {config.top_module}")
    print(f"  PDK: {config.pdk}")
    print(f"  Netlist: {config.netlist}")
    print(f"  Die Area: {config.die_area}")
