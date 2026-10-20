"""Validate named engineering evidence before opening the frozen formal plan."""
import argparse
from pathlib import Path
from common import ROOT, desc, load, save, sha

REQUIRED = ('holdout_inputs', 'parameters_frontend', 'parameters_backend', 'cache',
            'DP_scope', 'prefix_AES', 'prefix_Salsa', 'GP_partitions',
            'real_Flash', 'same_session_resume', 'budget_cutoff', 'owned_processes',
            'deterministic_controllers')
CRITICAL = ('common.py','study_contract.py','legacy_backend.py','pl_backend.py',
            'native_session.py','work_budget.py','evaluation_cache.py','legal_refinement.py',
            'rudy_direct.py','rudy_adapter.py','physical_observation.py','surplus.py',
            'policy_menu.py','policy_controller.py','prepare_episode.py','episode_runner.py',
            'process_supervisor.py')


def release(manifest_path, plan_path, output):
    manifest=load(manifest_path);checks={};records={}
    for name in REQUIRED:
        item=manifest['evidence'][name]
        checks[name+'_unchanged']=sha(item['path'])==item['sha256']
        records[name]=load(item['path'])
        checks[name+'_passed']=records[name].get('ok')is True
    # Evidence may have multiple technical runs. Every required module must
    # match its final tested source, rather than borrowing a previous version's
    # passing badge after a runtime change.
    tested=manifest['tested_sources']
    for name in CRITICAL:
        checks['source_'+name]=sha(ROOT/name)==tested[name]
    checks['source_plugin']=sha(ROOT/'plugin/lib/index.js')==tested['plugin/lib/index.js']
    suite=load(ROOT/'suite.json');plan=load(plan_path)
    checks['frozen_kernel_unchanged']=sha(suite['solver']['path'])==suite['solver']['sha256']=='f3f62b12432225494c0506bd4be934ff9da7d5b27d07d3c45e82175568885ec4'
    checks['twelve_designs']=len(suite['designs'])==12
    checks['seventy_two_main_episodes']=len(plan['agent'])==36 and len(plan['rule'])==36
    checks['fixed_model']=plan['model']=='deepseek-flash'and plan['effort']=='max'
    result={'ok':all(checks.values()),'checks':checks,'evidence_manifest':desc(manifest_path),
            'tested_sources':tested,'scope':'Engineering gate only, no controller QoR or publication claim.'}
    output=Path(output)
    if output.exists():raise FileExistsError(output)
    save(output,result)
    if result['ok']:
        plan.update(study_phase='formal',formal_gate='open',gate_evidence=desc(output))
        unlocked=output.with_name('released-plan.json')
        if unlocked.exists():raise FileExistsError(unlocked)
        save(unlocked,plan)
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--evidence',required=True);parser.add_argument('--plan',required=True);parser.add_argument('--output',required=True)
    args=parser.parse_args();value=release(args.evidence,args.plan,args.output)
    print(value['ok'])
    if not value['ok']:raise SystemExit(1)
