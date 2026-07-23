#!/bin/bash
# 修复nangate45和ics55设计的TCL脚本路径

DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"

echo "=========================================="
echo "修复nangate45和ics55的TCL脚本"
echo "=========================================="
echo ""

# 修复nangate45设计
for design in aes_nangate45_a aes_nangate45_b aes_nangate45_t; do
    echo "修复 $design..."

    TCL_FILE="$DESIGNS_DIR/$design/workspace/script/DB_script/db_path_setting.tcl"

    if [ -f "$TCL_FILE" ]; then
        # 备份
        cp "$TCL_FILE" "${TCL_FILE}.bak"

        # 替换sky130路径为nangate45路径
        cat > "$TCL_FILE" << 'EOF'
set DB_LEF_PATH "$::env(FOUNDRY_DIR)/lef"
set DB_LIB_PATH "$::env(FOUNDRY_DIR)/lib"

#===========================================================
##   set tech lef and cells lef path for nangate45
#===========================================================
set TECH_LEF_PATH "$DB_LEF_PATH/NangateOpenCellLibrary.tech.lef"
set LEF_PATH "$DB_LEF_PATH/NangateOpenCellLibrary.macro.lef"

#===========================================================
##   set lib path
#===========================================================
set LIB_FILES [list \
  "$DB_LIB_PATH/NangateOpenCellLibrary_typical.lib" \
]

#===========================================================
##   set sdc path
#===========================================================
set SDC_PATH "$::env(SDC_FILE)"

#===========================================================
##   set netlist path
#===========================================================
set NETLIST_FILES [list \
  "$::env(NETLIST_FILE)" \
]

#===========================================================
##   set DEF path (optional, only for incremental flow)
#===========================================================
if { [info exists ::env(DEF_FILE)] } {
    set DEF_PATH "$::env(DEF_FILE)"
}
EOF

        echo "  ✓ Fixed $design"
    fi
done

echo ""

# 修复ics55设计
for design in aes_ics55_a aes_ics55_b aes_ics55_t; do
    echo "修复 $design..."

    TCL_FILE="$DESIGNS_DIR/$design/workspace/script/DB_script/db_path_setting.tcl"

    if [ -f "$TCL_FILE" ]; then
        # 备份
        cp "$TCL_FILE" "${TCL_FILE}.bak"

        # 替换为ics55路径
        cat > "$TCL_FILE" << 'EOF'
set DB_LEF_PATH "$::env(FOUNDRY_DIR)/prtech/techLEF"
set DB_LIB_PATH "$::env(FOUNDRY_DIR)/prtech/signalStormCellLib"

#===========================================================
##   set tech lef and cells lef path for ics55
#===========================================================
set TECH_LEF_PATH "$DB_LEF_PATH/N551P6M_ieda.lef"
set LEF_PATH "$DB_LIB_PATH/signalStorm55_lef.lef"

#===========================================================
##   set lib path
#===========================================================
set LIB_FILES [list \
  "$DB_LIB_PATH/signalStorm55_tt.lib" \
]

#===========================================================
##   set sdc path
#===========================================================
set SDC_PATH "$::env(SDC_FILE)"

#===========================================================
##   set netlist path
#===========================================================
set NETLIST_FILES [list \
  "$::env(NETLIST_FILE)" \
]

#===========================================================
##   set DEF path (optional, only for incremental flow)
#===========================================================
if { [info exists ::env(DEF_FILE)] } {
    set DEF_PATH "$::env(DEF_FILE)"
}
EOF

        echo "  ✓ Fixed $design"
    fi
done

echo ""
echo "=========================================="
echo "TCL脚本修复完成！"
echo "=========================================="
