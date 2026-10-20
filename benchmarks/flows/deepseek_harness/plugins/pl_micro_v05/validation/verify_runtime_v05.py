"""Cache-input sensitivity and real frozen-native cancellation regressions."""
import argparse
import copy
import importlib.util
import json
import shutil
import time
from pathlib import Path
from unittest.mock import patch
from common import ROOT, load, save, pid_identity
from evaluation_cache import EvaluationCache
from native_session import NativeSession
import work_budget


def run(identifier):
    target = ROOT / 'technical' / identifier
    target.mkdir(parents=True, exist_ok=False)
    suite = load(ROOT / 'suite.json')
    design = copy.deepcopy(suite['designs']['gcd_nangate45_a'])
    checks = {}
    cache = EvaluationCache()
    final_def = ROOT / 'references/gcd_nangate45_a/ieda/attempt-1/placement.def'
    if not final_def.exists():
        final_def = Path(load(ROOT / 'references/gcd_nangate45_a/ieda/attempt-1/result.json')['metrics']['def']['path'])
    key, context = cache.fingerprint(design, final_def)
    outcomes = []
    for field in ('input_def', 'pl_config', 'sdc', 'tech_lef', 'macro_lef', 'libs', 'cell_lefs'):
        variant = copy.deepcopy(design)
        source = design[field][0] if isinstance(design[field], list) else design[field]
        private = target / ('variant-' + field)
        shutil.copy2(source, private)
        if isinstance(design[field], list): variant[field][0] = str(private)
        else: variant[field] = str(private)
        before, _ = cache.fingerprint(variant, final_def)
        with private.open('a') as stream: stream.write('\n# fingerprint-only changed input\n')
        after, _ = cache.fingerprint(variant, final_def)
        outcomes.append({'input': field, 'content_change_invalidates': before != after})
    corner = {**design, 'measurement_corner': 'changed-for-fingerprint-check'}
    corner_key, _ = cache.fingerprint(corner, final_def)
    checks['all_measurement_input_content_changes_invalidate'] = all(x['content_change_invalidates'] for x in outcomes)
    checks['corner_and_metadata_changes_invalidate'] = corner_key != key
    checks['kernel_and_evaluator_are_fingerprinted'] = (
        str(Path(suite['solver']['path']).resolve()) in context['assets']
        and any(name.endswith('/common.py') for name in context['assets'])
        and any(name.endswith('/evaluation_cache.py') for name in context['assets']))
    clone = target / 'same.def'; shutil.copy2(final_def, clone)
    clone_key, _ = cache.fingerprint(design, clone)
    checks['DEF_filename_does_not_change_key'] = clone_key == key
    with clone.open('a') as stream: stream.write('\n# changed bytes\n')
    changed_key, _ = cache.fingerprint(design, clone)
    checks['DEF_content_changes_invalidate'] = changed_key != key

    # Native initialization plus a bounded Tcl CPU loop. The loop is not an
    # optimizer or an experimental episode; it verifies hard cancellation of
    # an owned real interpreter and retained failed-RPC cost.
    budget = work_budget.WorkBudget({'physical_cpu_seconds': 30, 'fresh_sta': 1, 'neighbor_trials': 1})
    work_budget.ACTIVE = budget
    native = None
    try:
        native = NativeSession(suite['solver']['path'], design, target / 'native', design['pl_config'], time.monotonic() + 30)
        identity = native.identity
        checks['real_native_one_CPU_affinity']=__import__('os').sched_getaffinity(native.proc.pid)=={__import__('common').native_cpu()}
        budget.limits['physical_cpu_seconds'] = budget.cpu() + budget.cleanup_cpu_reserve_s + .3
        interrupted = False
        try:
            native.call(['for {set i 0} {$i < 1000000000} {incr i} {}'], 'CPU-cutoff-probe')
        except work_budget.BudgetExhausted:
            interrupted = True
        checks['real_native_CPU_cutoff_interrupts_RPC'] = interrupted
        checks['cutoff_leaves_no_owned_native'] = pid_identity(identity['pid']) is None
        checks['CPU_including_cleanup_within_cap'] = budget.cpu() <= budget.limits['physical_cpu_seconds']
        ledger = [json.loads(s) for s in (target / 'native/rpc-ledger.jsonl').read_text().splitlines()]
        checks['failed_RPC_cost_retained'] = any(row.get('completed') is False and row.get('native_cpu_s', 0) > 0 for row in ledger)
    finally:
        if native: native.close()
        work_budget.ACTIVE = None
    value = {'ok': all(checks.values()), 'checks': checks, 'input_variants': outcomes,
             'work': budget.view(), 'purpose': 'technical checks only, no controller result or free geometry'}
    save(target / 'result.json', value)
    print(json.dumps(value), flush=True)
    if not value['ok']: raise SystemExit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--id', required=True)
    run(parser.parse_args().id)
