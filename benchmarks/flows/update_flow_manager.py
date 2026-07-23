#!/usr/bin/env python3
"""
更新 flow_manager.py 以集成 TCL 生成器
"""

# 在 flow_manager.py 中添加对 tcl_generator 的调用
import sys
sys.path.insert(0, '/home/lxq/AiEDA/iEDA.ai/benchmarks/flows')

from tcl_generator import TCLGenerator

# 添加到 FlowManager 类的方法实现
def _gen_db_scripts(self, config, script_dir):
    TCLGenerator.gen_db_init_lef(script_dir)
    TCLGenerator.gen_db_path_setting(script_dir)

def _gen_ifp_script(self, config, script_dir):
    TCLGenerator.gen_ifp_script(config, script_dir)

def _gen_ipl_script(self, config, script_dir):
    TCLGenerator.gen_ipl_script(config, script_dir)

def _gen_icts_script(self, config, script_dir):
    TCLGenerator.gen_icts_script(config, script_dir)

def _gen_irt_script(self, config, script_dir):
    TCLGenerator.gen_irt_script(config, script_dir)

def _gen_ito_script(self, config, script_dir):
    TCLGenerator.gen_ito_script(config, script_dir)

def _gen_report_scripts(self, config, script_dir):
    TCLGenerator.gen_ista_script(config, script_dir)
    TCLGenerator.gen_ipw_script(config, script_dir)
    TCLGenerator.gen_idrc_script(config, script_dir)
    TCLGenerator.gen_gds_script(config, script_dir)

print("✓ TCL生成器方法定义完成")
