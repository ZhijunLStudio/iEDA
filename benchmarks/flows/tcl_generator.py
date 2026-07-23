#!/usr/bin/env python3
"""
TCL 脚本生成器 - 基于设计配置动态生成各阶段 TCL 脚本
"""

from pathlib import Path
from typing import Dict

class TCLGenerator:
    """TCL 脚本生成器"""
    
    @staticmethod
    def gen_db_init_lef(script_dir: Path):
        """生成 LEF 初始化脚本"""
        (script_dir / "DB_script").mkdir(exist_ok=True)
        
        tcl = """#===========================================================
##   read lef
#===========================================================
tech_init -path [lindex $::env(TECH_LEF_PATH) 0]
lef_init -path $::env(CELLS_LEF_PATH)
"""
        with open(script_dir / "DB_script" / "db_init_lef.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_db_path_setting(script_dir: Path):
        """生成路径设置脚本"""
        tcl = """#===========================================================
##   set result path
#===========================================================
set RESULT $::env(RESULT_DIR)
"""
        with open(script_dir / "DB_script" / "db_path_setting.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_ifp_script(config, script_dir: Path):
        """生成 Floorplan 脚本"""
        (script_dir / "iFP_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   init flow config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json

#===========================================================
##   read db config
#===========================================================
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)

#===========================================================
##   reset data path
#===========================================================
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl

#===========================================================
##   read lef
#===========================================================
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read verilog
#===========================================================
verilog_init -path $::env(NETLIST_FILE) -top $::env(DESIGN_TOP)

#===========================================================
##   init floorplan
#===========================================================
set DIE_AREA $::env(DIE_AREA)
set CORE_AREA $::env(CORE_AREA)
set PLACE_SITE unit

floorplan_init \\
    -die_area $DIE_AREA \\
    -core_area $CORE_AREA \\
    -core_site $PLACE_SITE

#===========================================================
##   tapcell
#===========================================================
tapcell_init \\
    -tapcell {config.pdk}_tap \\
    -distance 25 \\
    -endcap {config.pdk}_fill

#===========================================================
##   Place IO Pin
#===========================================================
io_init

#===========================================================
##   write def
#===========================================================
def_save -path $RESULT/iFP_result.def

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iFP_script" / "run_iFP.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_ipl_script(config, script_dir: Path):
        """生成 Placement 脚本"""
        (script_dir / "iPL_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iFP_result.def

#===========================================================
##   read sdc
#===========================================================
sdc_init -path $::env(SDC_FILE)

#===========================================================
##   Global Placement
#===========================================================
global_place

#===========================================================
##   Legalization
#===========================================================
legalization

#===========================================================
##   Detailed Placement
#===========================================================
detailed_place

#===========================================================
##   write def
#===========================================================
def_save -path $RESULT/iPL_result.def

#===========================================================
##   report
#===========================================================
report_wirelength
report_congestion -path $RESULT/iPL_congestion.rpt

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iPL_script" / "run_iPL.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_icts_script(config, script_dir: Path):
        """生成 Clock Tree Synthesis 脚本"""
        (script_dir / "iCTS_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iPL_result.def

#===========================================================
##   read sdc
#===========================================================
sdc_init -path $::env(SDC_FILE)

#===========================================================
##   run CTS
#===========================================================
cts_init -config $::env(CONFIG_DIR)/cts_default_config.json

#===========================================================
##   write def
#===========================================================
def_save -path $RESULT/iCTS_result.def

#===========================================================
##   report
#===========================================================
report_cts

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iCTS_script" / "run_iCTS.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_irt_script(config, script_dir: Path):
        """生成 Routing 脚本"""
        (script_dir / "iRT_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iCTS_result.def

#===========================================================
##   read sdc
#===========================================================
sdc_init -path $::env(SDC_FILE)

#===========================================================
##   run Routing
#===========================================================
run_route

#===========================================================
##   write def
#===========================================================
def_save -path $RESULT/iRT_result.def

#===========================================================
##   report
#===========================================================
report_route

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iRT_script" / "run_iRT.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_ito_script(config, script_dir: Path):
        """生成 Timing Optimization 脚本"""
        (script_dir / "iTO_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iRT_result.def

#===========================================================
##   read sdc
#===========================================================
sdc_init -path $::env(SDC_FILE)

#===========================================================
##   run Timing Optimization
#===========================================================
run_to -drv
run_to -hold

#===========================================================
##   write def
#===========================================================
def_save -path $RESULT/iTO_result.def

#===========================================================
##   report
#===========================================================
report_to

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iTO_script" / "run_iTO.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_ista_script(config, script_dir: Path):
        """生成 STA 脚本"""
        (script_dir / "iSTA_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iTO_result.def

#===========================================================
##   read sdc
#===========================================================
sdc_init -path $::env(SDC_FILE)

#===========================================================
##   run STA
#===========================================================
run_sta

#===========================================================
##   report timing
#===========================================================
report_timing -path $RESULT/timing_report.txt
report_wns -path $RESULT/wns_report.txt
report_tns -path $RESULT/tns_report.txt

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iSTA_script" / "run_iSTA.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_ipw_script(config, script_dir: Path):
        """生成 Power Analysis 脚本"""
        (script_dir / "iPW_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iTO_result.def

#===========================================================
##   read sdc
#===========================================================
sdc_init -path $::env(SDC_FILE)

#===========================================================
##   run Power Analysis
#===========================================================
run_power

#===========================================================
##   report power
#===========================================================
report_power -path $RESULT/power_report.txt

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iPW_script" / "run_iPW.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_idrc_script(config, script_dir: Path):
        """生成 DRC 脚本"""
        (script_dir / "iDRC_script").mkdir(exist_ok=True)
        
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iTO_result.def

#===========================================================
##   run DRC
#===========================================================
run_drc

#===========================================================
##   report DRC
#===========================================================
report_drc -path $RESULT/drc_report.txt

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "iDRC_script" / "run_iDRC.tcl", 'w') as f:
            f.write(tcl)
    
    @staticmethod
    def gen_gds_script(config, script_dir: Path):
        """生成 GDS 转换脚本"""
        tcl = f"""#===========================================================
##   read config
#===========================================================
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

#===========================================================
##   read def
#===========================================================
def_init -path $RESULT/iTO_result.def

#===========================================================
##   convert to GDS
#===========================================================
gds_save -path $RESULT/final.gds

#===========================================================
##   Exit
#===========================================================
flow_exit
"""
        with open(script_dir / "DB_script" / "run_def_to_gds.tcl", 'w') as f:
            f.write(tcl)

if __name__ == "__main__":
    print("TCL Generator ready")
