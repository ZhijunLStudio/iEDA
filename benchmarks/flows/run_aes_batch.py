#!/usr/bin/env python3
"""
批量运行 AES 设计的所有版本
"""

import sys
import json
from pathlib import Path
from datetime import datetime
from flow_manager import FlowManager

def get_aes_designs(benchmark_root: Path) -> list:
    """获取所有 AES 设计"""
    designs_dir = benchmark_root / "designs"
    aes_designs = []
    
    for design_dir in designs_dir.iterdir():
        if design_dir.is_dir() and design_dir.name.startswith("aes"):
            config_file = design_dir / "design.json"
            if config_file.exists():
                aes_designs.append(design_dir.name)
    
    return sorted(aes_designs)

def main():
    benchmark_root = Path("/home/lxq/AiEDA/iEDA.ai/benchmarks")
    manager = FlowManager(benchmark_root)
    
    # 获取所有 AES 设计
    aes_designs = get_aes_designs(benchmark_root)
    
    print(f"\n{'='*70}")
    print(f"AES 批量运行工具")
    print(f"{'='*70}")
    print(f"\n找到 {len(aes_designs)} 个 AES 设计:\n")
    
    # 按 PDK 分组显示
    pdk_groups = {}
    for design in aes_designs:
        parts = design.split('_')
        if len(parts) >= 3:
            pdk = parts[-2]  # aes_sky130_a -> sky130
            strategy = parts[-1]  # aes_sky130_a -> a
            key = f"{pdk}"
            if key not in pdk_groups:
                pdk_groups[key] = []
            pdk_groups[key].append((design, strategy))
    
    for pdk, designs in sorted(pdk_groups.items()):
        print(f"  {pdk}:")
        for design, strategy in designs:
            strategy_map = {'a': 'area', 'b': 'balance', 't': 'timing'}
            strategy_name = strategy_map.get(strategy, strategy)
            print(f"    - {design} ({strategy_name})")
        print()
    
    # 询问用户
    print("选项:")
    print("  1. 运行所有设计")
    print("  2. 按 PDK 运行")
    print("  3. 运行单个设计")
    print("  4. 退出")
    
    choice = input("\n请选择 (1-4): ").strip()
    
    selected_designs = []
    
    if choice == "1":
        selected_designs = aes_designs
    elif choice == "2":
        print(f"\n可用 PDK: {', '.join(sorted(pdk_groups.keys()))}")
        pdk = input("请输入 PDK: ").strip()
        if pdk in pdk_groups:
            selected_designs = [d[0] for d in pdk_groups[pdk]]
        else:
            print(f"错误: PDK '{pdk}' 不存在")
            return
    elif choice == "3":
        print("\n可用设计:")
        for i, design in enumerate(aes_designs, 1):
            print(f"  {i}. {design}")
        idx = int(input("\n请输入序号: ").strip()) - 1
        if 0 <= idx < len(aes_designs):
            selected_designs = [aes_designs[idx]]
        else:
            print("错误: 无效序号")
            return
    else:
        print("退出")
        return
    
    # 运行选中的设计
    print(f"\n{'='*70}")
    print(f"准备运行 {len(selected_designs)} 个设计")
    print(f"{'='*70}\n")
    
    confirm = input("确认开始运行? (y/n): ").strip().lower()
    if confirm != 'y':
        print("取消运行")
        return
    
    # 批量运行
    all_results = []
    start_time = datetime.now()
    
    for i, design_name in enumerate(selected_designs, 1):
        print(f"\n{'#'*70}")
        print(f"# [{i}/{len(selected_designs)}] {design_name}")
        print(f"{'#'*70}\n")
        
        try:
            config = manager.load_design_config(design_name)
            results = manager.run_flow(config)
            all_results.append(results)
        except Exception as e:
            print(f"\n✗ 设计 {design_name} 运行失败: {e}")
            all_results.append({
                "design": design_name,
                "error": str(e)
            })
    
    # 总结
    elapsed = datetime.now() - start_time
    print(f"\n{'='*70}")
    print(f"批量运行完成")
    print(f"{'='*70}")
    print(f"总耗时: {elapsed}")
    print(f"成功: {sum(1 for r in all_results if 'error' not in r)}/{len(all_results)}")
    
    # 保存总结报告
    summary_file = benchmark_root / "flows" / "aes_batch_results.json"
    summary = {
        "timestamp": start_time.isoformat(),
        "elapsed_sec": elapsed.total_seconds(),
        "total_designs": len(selected_designs),
        "results": all_results
    }
    
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)
    
    print(f"\n汇总报告已保存: {summary_file}")
    
    # 显示失败的设计
    failed = [r for r in all_results if 'error' in r]
    if failed:
        print(f"\n失败的设计 ({len(failed)}):")
        for r in failed:
            print(f"  - {r['design']}: {r['error']}")

if __name__ == "__main__":
    main()
