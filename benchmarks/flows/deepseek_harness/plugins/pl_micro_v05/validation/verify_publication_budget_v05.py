#!/usr/bin/env python3
"""Real near-budget DP publication/cutoff regression; engineering fixture only."""
import argparse
import json
from pathlib import Path
import time
from common import ROOT, load, save, sha
from pl_backend import PlacementSession


def run(master, identifier):
    root = ROOT / 'episodes' / identifier
    root.mkdir(parents=True, exist_ok=False)
    budget = dict(next(iter(load(ROOT / 'paired-plan.json')['arms'].values()))['budget'])
    save(root / 'episode.json', {'design': 'aes', 'budget': budget,
         'deadline_unix': time.time() + budget['wall_seconds'],
         'purpose': 'Engineering fixture, no agent/controller QoR result or free main candidate'})
    actor = PlacementSession(root)
    checks, calls, error = {}, [], None

    def call(op, **args):
        response = actor.handle({'op': op, 'args': args})
        calls.append({'op': op, 'ok': response['ok'], 'error_class': response.get('error_class'),
                      'physical_CPU_s': response.get('budget', {}).get('physical_cpu_s')})
        return response

    try:
        source = load(master / 'main-v1/episodes/c07-r0/legal-candidates/l19/result.json')
        parent_path = Path(source['def']['path'])
        original = sha(parent_path)
        proposal = actor._new_proposal(parent_path, snapshot='engineering-only',
                    stages='engineering-fixture', run_dp=True, native={}, no_change=False)
        parent = call('evaluate', proposal_id=proposal)
        if not parent['ok']:
            raise RuntimeError('Fresh fixture evaluation failed: ' + str(parent))
        checks['parent_freshly_measured_and_qualified'] = (
            parent['assessment']['surplus']['qualified'] and actor.work.fresh_sta == 1)
        refined = call('refine', candidate_id=parent['candidate_id'], evaluation='immediate',
                       action={'objective': 'balanced', 'operator': 'row_opt', 'scope': 'global',
                               'protect_reported_timing': False, 'strength': 4})
        proof_path = root / 'transactions/t0000/proof.json'
        proof = load(proof_path) if proof_path.exists() else {}
        checks['native_DP_completed_before_publication'] = bool(proof.get('native', {}).get('ok'))
        checks['large_DP_result_published'] = proof.get('changed_count', 0) >= 10000
        checks['complete_evaluation_cut_off_by_CPU'] = (
            refined.get('ok') is False and refined.get('error_class') == 'BudgetExhausted')
        checks['failed_fresh_evaluation_charged'] = actor.work.fresh_sta == 2
        checks['immutable_parent_unchanged'] = sha(parent_path) == original
        failed = [key for key, value in actor.legals.items() if not value['ok']]
        rejected = call('finish', candidate_id=failed[-1] if failed else 'unmeasured',
                        stop_reason='quota_exhausted')
        checks['failed_evaluation_cannot_deliver'] = not rejected['ok'] and not (root / 'final.def').exists()
        delivered = call('finish', candidate_id=parent['candidate_id'], stop_reason='quota_exhausted')
        checks['measured_parent_explicitly_delivered'] = bool(delivered['ok'] and sha(root / 'final.def') == original)
    except Exception as exc:
        error = type(exc).__name__ + ': ' + str(exc)
    finally:
        actor.close_native()
        work = actor.work.view()
        checks['actual_CPU_including_cleanup_within_cap'] = work['physical_cpu_s'] <= budget['physical_cpu_seconds']
        result = {'ok': error is None and all(checks.values()), 'checks': checks, 'error': error,
                  'work': work, 'calls': calls, 'kernel_sha256': actor.suite['solver']['sha256'],
                  'native_CPU_affinity': 'one logicalCPU per native process', 'model_requests': 0,
                  'purpose': 'Engineering-only fixture; parent is freshly reevaluated within this110CPU budget. No main result is replaced.'}
        save(root / 'validation-result.json', result)
        print(json.dumps(result), flush=True)
    if not result['ok']:
        raise SystemExit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--master', required=True, type=Path)
    parser.add_argument('--id', required=True)
    args = parser.parse_args()
    run(args.master.resolve(), args.id)
