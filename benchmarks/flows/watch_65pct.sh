#!/bin/bash
# 实时监控 65% 流程进度

RESULT_DIR="benchmarks/results/aes13_65pct"

while true; do
  clear
  echo "=========================================="
  echo "AES13 65% 利用率流程实时监控"
  echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "=========================================="
  echo

  # 检查进程
  if pgrep -f "aes13_flow.py.*65pct" > /dev/null; then
    echo "✓ 流程正在运行"
    echo "  PID: $(pgrep -f 'aes13_flow.py.*65pct')"
  else
    echo "✗ 流程未运行"
  fi
  echo

  # 各阶段统计
  echo "阶段完成统计:"
  echo "----------------------------------------"
  printf "%-15s %3s %3s %3s %3s %3s\n" "PDK" "FP" "PL" "CTS" "RT" "GDS"

  for pdk in sky130 nangate45 asap7 ics55; do
    fp=0; pl=0; cts=0; rt=0; gds=0
    for variant in a b t; do
      design="aes_${pdk}_${variant}"
      [ -f "$RESULT_DIR/$design/workspace/result/iFP_result.def" ] && ((fp++))
      [ -f "$RESULT_DIR/$design/workspace/result/iPL_result.def" ] && ((pl++))
      [ -f "$RESULT_DIR/$design/workspace/result/iCTS_result.def" ] && ((cts++))
      [ -f "$RESULT_DIR/$design/workspace/result/iRT_result.def" ] && ((rt++))
      [ -f "$RESULT_DIR/$design/workspace/result/final.gds" ] && ((gds++))
    done
    printf "%-15s %3d %3d %3d %3d %3d\n" "$pdk" $fp $pl $cts $rt $gds
  done

  echo
  echo "总计:"
  fp_total=$(find "$RESULT_DIR" -name "iFP_result.def" 2>/dev/null | wc -l)
  pl_total=$(find "$RESULT_DIR" -name "iPL_result.def" 2>/dev/null | wc -l)
  cts_total=$(find "$RESULT_DIR" -name "iCTS_result.def" 2>/dev/null | wc -l)
  rt_total=$(find "$RESULT_DIR" -name "iRT_result.def" 2>/dev/null | wc -l)
  gds_total=$(find "$RESULT_DIR" -name "final.gds" 2>/dev/null | wc -l)

  echo "  Floorplan: $fp_total/12"
  echo "  Placement: $pl_total/12"
  echo "  CTS:       $cts_total/12"
  echo "  Routing:   $rt_total/12"
  echo "  GDS:       $gds_total/12"

  echo
  echo "按 Ctrl+C 退出监控"
  sleep 30
done
