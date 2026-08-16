#!/usr/bin/env python3
"""Per-stage multi-scope GP chain.

At every parent checkpoint the script branches longnet/hotspot/random local
candidates against the same global control, keeps every child checkpoint, and
chooses the best one with the same policy as the search matrix. The winner
becomes the parent of the next stage, so local GP is allowed to win whenever it
actually dominates/tradeoffs better.
"""
from __future__ import annotations
import argparse, json, re, shlex, sys, shutil
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from flows.gp_agent import REPO_ROOT, run_ieda

PLV_CASES_ROOT = Path('/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases')

def metrics(path):
    d = json.loads(Path(path).read_text())
    return {'iter': d.get('current_iter'), 'hpwl': int(d.get('prev_hpwl', 0)), 'overflow': float(d.get('sum_overflow', 0.0))}

def choose_best(cands, target):
    best = None
    for c in cands:
        m = c['metrics']
        feasible = m['overflow'] <= target + 1e-5
        better = False
        if best is None: better = True
        else:
            bm = best['metrics']
            if feasible != best['feasible']: better = feasible
            elif feasible: better = m['hpwl'] < bm['hpwl']
            else: better = m['overflow'] < bm['overflow'] or (m['overflow'] == bm['overflow'] and m['hpwl'] < bm['hpwl'])
        if better:
            best = {'name': c['name'], 'path': c['path'], 'metrics': m, 'feasible': feasible}
    return best

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--design', required=True)
    ap.add_argument('--workdir', default='/tmp/gp_multiscope_chain')
    ap.add_argument('--start', type=int, default=20)
    ap.add_argument('--stage-budget', type=int, default=20)
    ap.add_argument('--stage-count', type=int, default=19)
    ap.add_argument('--scopes', nargs='+', default=['longnet','hotspot','random'])
    ap.add_argument('--penalty', type=float, default=2.0)
    ap.add_argument('--final-budget', type=int, default=200)
    args = ap.parse_args()
    case = PLV_CASES_ROOT / args.design
    input_def = REPO_ROOT / 'benchmarks/results/innovus_gp_compare' / args.design / 'ieda_in_unplaced.def'
    config = REPO_ROOT / 'benchmarks/results/innovus_gp_compare' / args.design / 'pl_clean_config.json'
    foundry = REPO_ROOT / 'scripts/foundry/sky130'
    work = Path(args.workdir) / args.design
    shutil.rmtree(work, ignore_errors=True); work.mkdir(parents=True)
    with open(config) as f: target = float(json.load(f)['PL']['GP']['Nesterov'].get('target_overflow', 0.1))

    # stage 0: global start
    rc, out, err = run_ieda(work, case, foundry, config, input_def,
        [f'placer_run_gp -mode start -iterations {args.start} -seed 42 -report_route_util 1',
         f'file copy -force {shlex.quote(str(work/"pl/gp_session_checkpoint.json"))} {shlex.quote(str(work/"parent_stage_0.json"))}',
         'placer_run_gp -mode close'])
    if rc != 0:
        print(json.dumps({'ok': False, 'stage': 0, 'rc': rc, 'err': err[-800:]})); return 1
    parent = work / 'parent_stage_0.json'
    history = []
    for stage in range(1, args.stage_count + 1):
        cmds = []
        for scope in args.scopes:
            sc = ['-scope', scope, '-scope_halo_coeff', '0.5', '-scope_halo_hops', '2']
            if scope == 'hotspot': sc += ['-scope_active_ratio', '0.2']
            if scope in ('random', 'longnet'): sc += ['-scope_active_count', '100']
            tag = f'stage{stage}_{scope}'
            cmds.append(f'puts "CAND_BEGIN {tag}"')
            cmds.append(f'placer_run_gp -mode restore -checkpoint {shlex.quote(str(parent))}')
            cmds.append(f'placer_run_gp -mode candidate -iterations {args.stage_budget} ' + ' '.join(sc) + f' -candidate_overflow_penalty {args.penalty}')
            cmds.append(f'catch {{file copy -force {shlex.quote(str(work/"pl/gp_candidate_local.json"))} {shlex.quote(str(work/f"{tag}_local.json"))}}}')
            cmds.append(f'catch {{file copy -force {shlex.quote(str(work/"pl/gp_candidate_global.json"))} {shlex.quote(str(work/f"{tag}_global.json"))}}}')
            cmds.append('placer_run_gp -mode close')
            cmds.append(f'puts "CAND_END {tag}"')
        rc, out, err = run_ieda(work, case, foundry, config, input_def, cmds)
        if rc != 0:
            print(json.dumps({'ok': False, 'stage': stage, 'rc': rc, 'err': err[-800:]})); return 1
        cands = []
        for scope in args.scopes:
            tag = f'stage{stage}_{scope}'
            for side in ['local','global']:
                p = work / f'{tag}_{side}.json'
                if p.exists(): cands.append({'name': f'{tag}_{side}', 'path': str(p), 'metrics': metrics(p)})
        chosen = choose_best(cands, target)
        if chosen is None:
            print(json.dumps({'ok': False, 'stage': stage, 'reason': 'no candidates'})); return 1
        parent = Path(chosen['path'])
        (work / f'parent_stage_{stage}.json').write_text(parent.read_text())
        history.append({'stage': stage, 'chosen': chosen['name'], 'hpwl': chosen['metrics']['hpwl'],
                        'overflow': chosen['metrics']['overflow'], 'feasible': chosen['feasible']})
        print(json.dumps(history[-1]))
    # final converge from chosen parent
    rc, out, err = run_ieda(work, case, foundry, config, input_def,
        [f'placer_run_gp -mode resume -checkpoint {shlex.quote(str(parent))} -iterations {args.final_budget} -report_route_util 1'],
        def_save=True)
    if rc != 0:
        print(json.dumps({'ok': False, 'stage': 'final', 'rc': rc, 'err': err[-800:]})); return 1
    m = re.search(r'iPL gp\.run \(resume, (\d+) iterations\).*?stop_reason=(\S+).*?iterations=(\d+)-(\d+) hpwl=(\d+) overflow=([0-9.eE+-]+).*?route_util=([0-9.eE+-]+)', out)
    final = {'ok': True, 'design': args.design, 'workdir': str(work), 'parent': str(parent), 'history': history,
             'gp': {'requested': int(m.group(1)) if m else None, 'stop': m.group(2) if m else None,
                    'start_iter': int(m.group(3)) if m else None, 'end_iter': int(m.group(4)) if m else None,
                    'hpwl': int(m.group(5)) if m else None, 'overflow': float(m.group(6)) if m else None,
                    'route_util': float(m.group(7)) if m else None}}
    (work / 'chain_result.json').write_text(json.dumps(final, indent=2))
    print(json.dumps(final, indent=2))
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
