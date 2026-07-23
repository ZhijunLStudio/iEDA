#!/bin/bash
# 为nangate45和ics55创建正确的track和PDN配置

DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"

echo "=========================================="
echo "为nangate45和ics55创建正确的层配置"
echo "=========================================="
echo ""

# Nangate45层配置
for design in aes_nangate45_a aes_nangate45_b aes_nangate45_t; do
    echo "配置 $design 的层..."

    TRACKS_FILE="$DESIGNS_DIR/$design/workspace/script/iFP_script/module/create_tracks.tcl"
    PDN_FILE="$DESIGNS_DIR/$design/workspace/script/iFP_script/module/pdn.tcl"

    # 创建tracks配置 (nangate45: metal1-10)
    cat > "$TRACKS_FILE" << 'EOF'
# Nangate45 track configuration
gern_track -layer metal1 -x_start 185 -x_step 370 -y_start 185 -y_step 370
gern_track -layer metal2 -x_start 240 -x_step 480 -y_start 240 -y_step 480
gern_track -layer metal3 -x_start 240 -x_step 480 -y_start 240 -y_step 480
gern_track -layer metal4 -x_start 480 -x_step 960 -y_start 480 -y_step 960
gern_track -layer metal5 -x_start 960 -x_step 1920 -y_start 960 -y_step 1920
EOF

    # 创建PDN配置
    cat > "$PDN_FILE" << 'EOF'
# Nangate45 PDN configuration
create_grid -layer_name metal1 -net_name_power VDD -net_name_ground VSS -width 0.48
set connect1 "metal1 metal4"
EOF

    echo "  ✓ $design 层配置完成"
done

echo ""

# ICS55层配置
for design in aes_ics55_a aes_ics55_b aes_ics55_t; do
    echo "配置 $design 的层..."

    TRACKS_FILE="$DESIGNS_DIR/$design/workspace/script/iFP_script/module/create_tracks.tcl"
    PDN_FILE="$DESIGNS_DIR/$design/workspace/script/iFP_script/module/pdn.tcl"

    # 创建tracks配置 (ics55: M1-M6)
    cat > "$TRACKS_FILE" << 'EOF'
# ICS55 track configuration
gern_track -layer M1 -x_start 150 -x_step 300 -y_start 150 -y_step 300
gern_track -layer M2 -x_start 200 -x_step 400 -y_start 200 -y_step 400
gern_track -layer M3 -x_start 200 -x_step 400 -y_start 200 -y_step 400
gern_track -layer M4 -x_start 400 -x_step 800 -y_start 400 -y_step 800
gern_track -layer M5 -x_start 800 -x_step 1600 -y_start 800 -y_step 1600
EOF

    # 创建PDN配置
    cat > "$PDN_FILE" << 'EOF'
# ICS55 PDN configuration
create_grid -layer_name M1 -net_name_power VDD -net_name_ground VSS -width 0.4
set connect1 "M1 M4"
EOF

    echo "  ✓ $design 层配置完成"
done

echo ""
echo "=========================================="
echo "层配置完成！"
echo "=========================================="
