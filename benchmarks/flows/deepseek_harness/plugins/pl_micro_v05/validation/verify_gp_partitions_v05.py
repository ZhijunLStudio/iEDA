"""Same feedback, actual GP iterations and geometry under two pause cadences."""
import argparse
import json
import time
from common import ROOT, load, save, sha
from pl_backend import PlacementSession


def run(design, identifier, efforts=(0, 3)):
    if not efforts or len(set(efforts)) != len(efforts) or any(e not in (0, 3, 4) for e in efforts):
        raise ValueError('Choose distinct supported feedback modes 0, 3 or 4')
    root = ROOT / 'episodes' / identifier; root.mkdir(parents=True, exist_ok=False)
    budget = dict(next(iter(load(ROOT / 'paired-plan.json')['arms'].values()))['budget'])
    budget.update(wall_seconds=1800, physical_cpu_seconds=1600)
    save(root / 'episode.json', {'design': design, 'budget': budget, 'deadline_unix': time.time() + 1800})
    actor = PlacementSession(root); rows = []; checks = {}
    def call(op, **args):
        value = actor.handle({'op': op, 'args': args})
        if not value['ok']: raise RuntimeError(str(value))
        return value
    try:
        for effort in efforts:
            pair = []
            for steps in (500, 100):
                config = {**actor.baseline_recipe['start'], 'steps': steps, 'congestion_effort': effort}
                node = call('start', **config)['snapshot']
                while node['can_advance'] and node['iteration'] < 500:
                    node = call('advance', snapshot_id=node['id'], steps=min(steps, 500-node['iteration']), scope='global', congestion_effort=effort)['snapshot']
                saved = actor.nodes[node['id']]
                pair.append({'steps_per_call': steps, 'actual_iterations': node['iteration'],
                             'raw_DEF_sha256': sha(saved['raw_def']), 'snapshot': node['id']})
            checks['feedback_%d_same_actual_iterations' % effort] = pair[0]['actual_iterations'] == pair[1]['actual_iterations']
            checks['feedback_%d_same_raw_DEF' % effort] = pair[0]['raw_DEF_sha256'] == pair[1]['raw_DEF_sha256']
            rows.append({'feedback': effort, 'arms': pair})
        before = actor.actual_steps
        restored = call('restore', snapshot_id=rows[0]['arms'][0]['snapshot'])
        checks['zero_GP_restore_exact_parent'] = restored['raw_def_bytes_equal'] and actor.actual_steps == before
        result = {'ok': all(checks.values()), 'design': design, 'checks': checks, 'rows': rows, 'work': actor.work.view()}
    except BaseException as exc:
        result = {'ok': False, 'design': design, 'checks': checks, 'rows': rows, 'error': type(exc).__name__ + ': ' + str(exc)}
        raise
    finally:
        actor.close_native(); actor._persist(); save(root / 'partition-result.json', result)
        print(json.dumps(result), flush=True)


if __name__ == '__main__':
    parser=argparse.ArgumentParser(); parser.add_argument('--design', required=True); parser.add_argument('--id', required=True)
    parser.add_argument('--effort', type=int, choices=(0, 3, 4), action='append', help='Repeat for multiple modes; default is 0 and 3')
    args=parser.parse_args(); run(args.design,args.id,tuple(args.effort)if args.effort else(0,3))
