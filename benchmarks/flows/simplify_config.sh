#!/bin/bash
# 简化配置，禁用复杂的PDN功能，快速验证

DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"

echo "=========================================="
echo "创建简化的Floorplan配置"
echo "=========================================="
echo ""

# 为nangate45创建简化的iFP脚本
for design in aes_nangate45_a aes_nangate45_b aes_nangate45_t; do
    echo "简化 $design..."

    # 备份原始run_iFP.tcl
    RUN_IFP="$DESIGNS_DIR/$design/workspace/script/iFP_script/run_iFP.tcl"

    if [ -f "$RUN_IFP" ]; then
        cp "$RUN_IFP" "${RUN_IFP}.full_backup"

        # 创建简化版本 - 跳过复杂的PDN和track配置
        cat > "$RUN_IFP" << 'EOFTCL'
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

# Read design
read_verilog $NETLIST_FILES
link_design $::env(DESIGN_TOP)

# Initialize floorplan with die area from environment
set die_area [split $::env(DIE_AREA)]
set die_llx [lindex $die_area 0]
set die_lly [lindex $die_area 1]
set die_urx [lindex $die_area 2]
set die_ury [lindex $die_area 3]

# Create floorplan
init_floorplan -die_area "$die_llx $die_lly $die_urx $die_ury" \
               -core_area "$die_llx $die_lly $die_urx $die_ury" \
               -core_site FreePDK45_38x28_10R_NP_162NW_34O

# Place IO pins
place_io_pin

# Write output
write_def $::env(RESULT_DIR)/iFP_result.def

puts "Simplified Floorplan completed"
exit
EOFTCL

        echo "  ✓ 简化完成: $design"
    fi
done

echo ""
echo "=========================================="
echo "简化配置完成！"
echo "=========================================="
