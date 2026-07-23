#!/usr/bin/env python3
"""
测试单个设计运行
"""
import sys
from pathlib import Path
from flow_manager import FlowManager

def main():
    benchmark_root = Path("/home/lxq/AiEDA/iEDA.ai/benchmarks")
    manager = FlowManager(benchmark_root)
    
    # 使用命令行参数或默认值
    design_name = sys.argv[1] if len(sys.argv) > 1 else "aes_sky130_a"
    
    print(f"\n测试运行设计: {design_name}\n")
    
    try:
        # 加载配置
        config = manager.load_design_config(design_name)
        
        # 运行流程（非 dry-run）
        results = manager.run_flow(config, dry_run=False)
        
        # 显示结果
        print(f"\n{'='*60}")
        print("运行完成")
        print(f"{'='*60}")
        
        if "failed_stage" in results:
            print(f"失败阶段: {results['failed_stage']}")
            print(f"查看日志: {config.result_dir}/{results['failed_stage']}.log")
            return 1
        else:
            print("所有阶段完成")
            print(f"结果目录: {config.result_dir}")
            return 0
    
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
