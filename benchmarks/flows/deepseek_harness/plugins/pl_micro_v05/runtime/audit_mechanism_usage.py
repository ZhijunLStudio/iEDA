#!/usr/bin/env python3
"""Describe actual tool use without executing or modifying any episode.

These counts are descriptive evidence, not a causal attribution or an ablation.
Only terminal episodes in the cohort's current receipt are included.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit(study):
    study = Path(study).resolve()
    receipt = study / 'cohort-progress.json'
    receipt_bytes = receipt.read_bytes()
    progress = json.loads(receipt_bytes)
    rows = []
    for identifier in sorted(progress['results']):
        root = study / 'episodes' / identifier
        result_path, ledger_path = root / 'result.json', root / 'tool-ledger.jsonl'
        if not result_path.exists() or not ledger_path.exists():
            rows.append({'id': identifier, 'readable': False,
                         'reason': 'terminal attempt lacks result or ledger'})
            continue
        result = json.loads(result_path.read_text())
        events = [json.loads(line) for line in ledger_path.read_text().splitlines() if line.strip()]
        attempts, successes, views, modes, errors = (Counter() for _ in range(5))
        gp, dp, swaps, trials = (Counter() for _ in range(4))
        measurement_responses, candidates = Counter(), {}
        prefix_ids, earlier_ids = set(), set()
        for event in events:
            response = event.get('response', {})
            if response.get('ok') is True:
                prefixes = response.get('prefix_proposal_ids', [])
                prefix_ids.update(prefixes)
                earlier_ids.update(p for p in prefixes if p != response.get('proposal_id'))
        cache_hits = no_change = dp_actions = moved_dp = selected_prefix = earlier_prefix = paginated = 0
        for event in events:
            request, response = event.get('request', {}), event.get('response', {})
            op, args = request.get('op', 'unknown'), request.get('args', {})
            attempts[op] += 1
            if response.get('ok') is not True:
                errors[response.get('error_class', 'unclassified')] += 1
                continue
            successes[op] += 1
            cache_hits += response.get('cache_hit') is True
            no_change += response.get('no_change') is True
            # A finish response repeats delivered metrics; it is not another
            # evaluation and has no assessment.surplus field. Cache hits are
            # responses too, but never additional distinct physical samples.
            if op in ('legalize', 'refine', 'evaluate') and response.get('metrics', {}).get('valid'):
                qualification = (response.get('assessment') or {}).get('surplus') or {}
                flag = qualification.get('qualified')
                category = 'qualified' if flag is True else 'unqualified' if flag is False else 'unknown'
                measurement_responses[category] += 1
                identifier_key = response.get('candidate_id')
                if identifier_key is not None:
                    candidate = {'qualification': category, 'violations': qualification.get('violations', [])}
                    if identifier_key in candidates and candidates[identifier_key] != candidate:
                        raise RuntimeError('Inconsistent qualification for immutable candidate ' + identifier_key)
                    candidates[identifier_key] = candidate
            if op == 'observe':
                views[args.get('view', 'summary')] += 1
                paginated += args.get('offset', 0) > 0
            if op in ('legalize', 'refine'):
                modes[args.get('evaluation', 'immediate')] += 1
            if op in ('start', 'advance'):
                gp[str(args.get('steps', 'unspecified'))] += 1
            if op == 'evaluate':
                selected_prefix += args.get('proposal_id') in prefix_ids
                earlier_prefix += args.get('proposal_id') in earlier_ids
            if op == 'refine':
                action = args.get('action', {})
                if action.get('operator') == 'rudy_swap':
                    swaps[str(action.get('max_moves', 'unspecified'))] += 1
                    trials[str(action.get('neighbor_trials', 'unspecified'))] += 1
                else:
                    dp_actions += 1
                    dp[str(action.get('max_selected_cells', 'unspecified'))] += 1
                    moved_dp += response.get('proof', {}).get('changed_count', 0) > 0
        audited = progress['results'][identifier].get('audit_ok') is True
        qualification_counts = Counter(c['qualification'] for c in candidates.values())
        binding_axes = Counter(axis for c in candidates.values() if c['qualification'] == 'unqualified'
                               for axis in c['violations'])
        rows.append({'id': identifier, 'readable': True, 'controller': result.get('controller'),
                     'design': result.get('design'), 'episode_ok': result.get('ok') is True,
                     'independent_audit_ok': audited,
                     'normal_delivery': result.get('ok') is True and audited,
                     'stop_reason': (result.get('delivery') or {}).get('stop_reason', 'no_delivery'),
                     'actual_work_at_stop': result.get('work'), 'actual_wall_s': result.get('wall_s'),
                     'evaluation_response_counts': dict(measurement_responses),
                     'distinct_candidate_qualification_counts': dict(qualification_counts),
                     'distinct_unqualified_candidate_axes': dict(binding_axes),
                     'attempted_tools': dict(attempts), 'successful_tools': dict(successes),
                     'observation_views': dict(views), 'paginated_observations': paginated,
                     'evaluation_modes': dict(modes), 'available_prefix_proposals': len(prefix_ids),
                     'explicitly_evaluated_prefixes': selected_prefix,
                     'explicitly_evaluated_earlier_prefixes': earlier_prefix,
                     'requested_GP_steps': dict(gp), 'DP_selected_cell_caps': dict(dp),
                     'accepted_swap_caps': dict(swaps), 'neighbor_trial_caps': dict(trials),
                     'successful_DP_actions': dp_actions, 'DP_actions_with_movement': moved_dp,
                     'no_change_responses': no_change, 'cache_hit_responses': cache_hits,
                     'tool_error_classes': dict(errors),
                     'evidence': {'result': str(result_path), 'result_sha256': digest(result_path),
                                  'ledger': str(ledger_path), 'ledger_sha256': digest(ledger_path)}})
    agents = [r for r in rows if r.get('controller') == 'agent' and r.get('readable')]
    # A controller label is authoritative; do not infer model execution from ID alone.
    totals = {}
    for key in ('attempted_tools', 'successful_tools', 'observation_views', 'evaluation_modes',
                'requested_GP_steps', 'DP_selected_cell_caps', 'accepted_swap_caps',
                'neighbor_trial_caps', 'tool_error_classes', 'evaluation_response_counts',
                'distinct_candidate_qualification_counts', 'distinct_unqualified_candidate_axes'):
        counter = Counter()
        for row in agents:
            counter.update(row[key])
        totals[key] = dict(counter)
    for key in ('available_prefix_proposals', 'explicitly_evaluated_prefixes',
                'explicitly_evaluated_earlier_prefixes', 'successful_DP_actions',
                'DP_actions_with_movement', 'no_change_responses', 'cache_hit_responses',
                'paginated_observations'):
        totals[key] = sum(row[key] for row in agents)
    totals['stop_reasons'] = dict(Counter(row['stop_reason'] for row in agents))
    return {'scope': 'Terminal actual episodes only; descriptive usage, not causal benefit.',
            'study': str(study),
            'cohort_receipt_sha256': hashlib.sha256(receipt_bytes).hexdigest(),
            'script_sha256': digest(Path(__file__)),
            'completed': progress['completed'], 'total': progress['total'],
            'agent_episodes': len(agents), 'agent_totals': totals, 'episodes': rows,
            'limitations': ['Successful requested caps are not actual executed work.',
                            'An immediate evaluation of the final proposal is not explicit prefix selection.',
                            'Finish repeats delivered metrics and is excluded from evaluation counts.',
                            'Repeated cache-hit responses are deduplicated only in distinct-candidate counts.',
                            'Cache/no-change counts do not imply free physical execution.',
                            'These observations do not change frozen strategies or main scores.']}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--study', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    value = audit(args.study)
    with Path(args.output).open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')
    print(json.dumps({k: value[k] for k in ('completed', 'total', 'agent_episodes', 'agent_totals')}))
