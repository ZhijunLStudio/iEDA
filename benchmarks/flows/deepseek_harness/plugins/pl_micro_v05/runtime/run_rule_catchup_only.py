#!/usr/bin/env python3
"""Complete individual-win rule catchups when aggregate main QoR fails.

The frozen driver's catchup body is reused verbatim up to its model-ablation
branch. No formal source, comparator policy, measurement or score is changed.
"""
import argparse
import ast
import hashlib
import importlib
import inspect
import json
import os
from pathlib import Path
import sys
import textwrap
import time


def load(path):
    return json.loads(Path(path).read_text())


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, value):
    path = Path(path)
    temp = path.with_name(path.name + '.tmp')
    temp.write_text(json.dumps(value, indent=2) + '\n')
    temp.replace(path)


def alive(identity):
    try:
        raw = Path('/proc', str(identity['pid']), 'stat').read_text()
        fields = raw[raw.rfind(')') + 2:].split()
        return int(fields[19]) == identity['start_ticks'] and fields[0] != 'Z'
    except (FileNotFoundError, ProcessLookupError):
        return False


def catchup_body(module):
    """Remove model-ablation statements; retain every catchup statement."""
    source = textwrap.dedent(inspect.getsource(module.Workflow.post_main))
    tree = ast.parse(source); function = tree.body[0]
    positions = [i for i, node in enumerate(function.body)
                 if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'ablation' for t in node.targets)]
    if len(positions) != 1:
        raise RuntimeError('Frozen post_main model boundary changed; refuse execution')
    function.body = function.body[:positions[0]] + [ast.Return(value=ast.Constant(value='rule_catchup_complete_no_additional_model_episodes'))]
    ast.fix_missing_locations(tree)
    literals = [n.value for n in ast.walk(tree) if isinstance(n, ast.Constant) and isinstance(n.value, str)]
    if any('ablation' in s for s in literals):
        raise RuntimeError('Model-ablation action survived catchup-only extraction')
    # The only materialized cohort has an explicitly empty model arm.
    if not any(isinstance(n, ast.keyword) and n.arg == 'agent' and isinstance(n.value, ast.List) and not n.value.elts for n in ast.walk(tree)):
        raise RuntimeError('Catchup plan does not explicitly prohibit model episodes')
    namespace = dict(vars(module))
    exec(compile(tree, '<frozen-catchup-only>', 'exec'), namespace)
    return namespace['post_main'], ast.unparse(tree) + '\n'


def driver_module(master):
    driver = master / 'driver-v7'
    os.environ['IEDA_STUDY_ROOT'] = str(driver)
    sys.path.insert(0, str(driver))
    return importlib.import_module('execute_validation')


def preflight(master, output):
    module = driver_module(master); function, source = catchup_body(module)
    inspected = {}
    class Captured(Exception):
        pass
    class FakeWorkflow:
        def materialize(self, name, plan):
            inspected.update(name=name, agent=plan['agent'], rule=plan['rule'], budget=plan['arms']['main']['budget'])
            raise Captured()
    try:
        function(FakeWorkflow(), master / 'main-v1', {'catchup_required': [{'strongest_rule_episode': 'c00-r0'}]})
    except Captured:
        pass
    else:
        raise AssertionError('Source-only preflight failed to stop before any experiment')
    budget = inspected['budget']
    checks = {'only_rule_cohort': inspected['name'] == 'catchup-v1' and inspected['agent'] == [] and len(inspected['rule']) == 1,
              'fixed_policy_preserved': inspected['rule'][0]['controller'] == 'coarse',
              'exact_predeclared_extra_caps': budget['physical_cpu_seconds'] == 4500 and budget['actual_gp_steps'] == 15000 and budget['starts'] == 8 and budget['fresh_sta'] == 30,
              'all_model_ablation_code_removed': 'ablations-v1' not in source and 'summarize_ablations' not in source}
    if not all(checks.values()):
        raise AssertionError(checks)
    if output.exists():
        raise FileExistsError(output)
    save(output, {'ok': True, 'checks': checks, 'native_or_API_runs': 0,
                  'frozen_driver': str(master / 'driver-v7/execute_validation.py'),
                  'frozen_driver_sha256': sha(master / 'driver-v7/execute_validation.py')})
    print(json.dumps({'preflight_ok': True, 'native_or_API_runs': 0}), flush=True)


def run(master):
    receipt = master / 'attempts/unconditional-catchup-started.json'
    final = master / 'audit/unconditional-catchup-summary.json'
    if receipt.exists() or final.exists():
        raise FileExistsError('Existing catchup followup; review rather than retry')
    raw = Path('/proc', str(os.getpid()), 'stat').read_text()
    fields = raw[raw.rfind(')') + 2:].split()
    save(receipt, {'identity': {'pid': os.getpid(), 'start_ticks': int(fields[19])},
                   'source_sha256': sha(__file__), 'phase': 'waiting_for_prior_controls', 'no_extra_model_episodes': True})
    previous = load(master / 'attempts/lg-recovery-closeout-v2-started.json')['identity']
    deadline = load(master / 'protocol/source-before.json')['deadline_unix']
    while alive(previous):
        if time.time() >= deadline:
            raise TimeoutError('Two-week deadline before individual-win catchup')
        time.sleep(15)
    # The prior control supervisor can exit on an error. Require its actual
    # terminal cohort evidence rather than treating process exit as success.
    recovery = load(master / 'audit/lg-recovery-control-summary.json')
    if recovery.get('completed') != recovery.get('total') or recovery.get('total') != 4:
        raise RuntimeError('Resolve incomplete recovery controls before catchup followup')
    main = master / 'main-v1'; decision = load(main / 'analysis-v1/decision.json')
    winners = decision['catchup_required']
    if decision['main_quality_gate_passed']:
        existing = load(master / 'catchup-v1/cohort-result.json')
        if existing.get('completed') != existing.get('total') or existing.get('total') != len(winners):
            raise RuntimeError('Positive main workflow catchup is incomplete; never duplicate it')
        save(final, {'scope': 'Existing positive-main catchup reused; no duplicate work', 'additional_model_episodes': 0,
                     'main_quality_gate_passed': True, 'cohort': str(master / 'catchup-v1/cohort-result.json')})
        return
    if not winners:
        save(final, {'scope': 'No actual individual wins or practical challenge gains; catchup not applicable',
                     'main_quality_gate_passed': False, 'additional_model_episodes': 0, 'required_cases': 0})
        return
    if (master / 'catchup-v1').exists():
        raise FileExistsError('Existing catchup root must be reviewed; do not overwrite or rerun')
    module = driver_module(master); function, source = catchup_body(module)
    workflow = module.Workflow(master, master / 'driver-v7-package', 'unconditional-catchup-workflow-v1')
    generated = workflow.receipts / 'frozen-catchup-only.py'
    generated.write_text(source)
    result = function(workflow, main, decision)
    cohort = load(master / 'catchup-v1/cohort-result.json')
    save(final, {'scope': 'Individual-win/practical-gain catchup after negative aggregate main result. Frozen policies, same originalDEF, independent cache; no new model episodes.',
                 'required_cases': len(winners), 'main_quality_gate_passed': False,
                 'additional_model_episodes': 0, 'cohort': str(master / 'catchup-v1/cohort-result.json'),
                 'cohort_sha256': sha(master / 'catchup-v1/cohort-result.json'), 'cohort_ok': cohort['ok'],
                 'decision': str(workflow.receipts / 'catchup-decision.json'),
                 'generated_rule_only_source': str(generated), 'generated_source_sha256': sha(generated),
                 'frozen_driver_sha256': sha(master / 'driver-v7/execute_validation.py'), 'returned_conclusion': result})
    workflow.state('all_individual_winner_rule_catchups_finished', main_quality_gate_passed=False, additional_model_episodes=0)
    print(json.dumps({'rule_only_catchup_finished': True, 'cases': len(winners)}), flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('--master', required=True, type=Path)
    p.add_argument('--preflight-output', type=Path)
    a = p.parse_args(); master = a.master.resolve()
    if a.preflight_output:
        preflight(master, a.preflight_output)
    else:
        try:
            run(master)
        except Exception as exc:
            path = master / 'audit/unconditional-catchup-error.json'
            if not path.exists():
                save(path, {'class': type(exc).__name__, 'error': str(exc), 'no_automatic_retry': True})
            raise
