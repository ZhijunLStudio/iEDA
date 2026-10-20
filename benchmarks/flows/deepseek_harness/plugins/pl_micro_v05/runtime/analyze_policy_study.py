"""Actual deliveries, actual costs, frozen gates; never pool the best repeats."""
import argparse
import csv
import json
import math
from pathlib import Path
from common import ROOT, load, save, desc, reference_gaps
from pl_backend import scalar_metrics
from surplus import AXES, HIGHER, POLICY, assess


def rank(metrics, target, period):
    value = reference_gaps(metrics, target, period)
    return (value['worst'], value['sum'])


def better(a, b):
    return a[0] < b[0] - 1e-12 or (abs(a[0] - b[0]) <= 1e-12 and a[1] < b[1] - 1e-12)


def practical_gain(a,b,target,period):
    ar,br=rank(a,target,period),rank(b,target,period)
    if br[0]>0 and ar[0]<=.9*br[0]:return True,'worst_gap_at_least_10_percent_lower'
    if ar[0]<=br[0]+1e-12 and any(b[k]>1e-9 and a[k]<=.95*b[k]for k in('rudy_peak','rudy_overflow_sum')):
        return True,'congestion_at_least_5_percent_lower_without_worst_gap_regression'
    return False,None


def matched(metrics, target):
    return all((target[k] - metrics[k] if k in HIGHER else metrics[k] - target[k])
               <= POLICY['epsilon'][k] for k in AXES)


def write_csv(path, rows):
    keys = list(dict.fromkeys(k for row in rows for k in row))
    with Path(path).open('x', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=keys)
        writer.writeheader(); writer.writerows(rows)


def analyze(output):
    output = Path(output); output.mkdir(parents=True, exist_ok=False)
    plan = load(ROOT / 'paired-plan.json'); suite = load(ROOT / 'suite.json')
    episodes = plan['rule'] + plan['agent']; records = {}; table = []; curves = []
    decisions = []; normal = 0; delivered = 0; all_deliveries_valid=True
    for design, specification in suite['designs'].items():
        period = specification['clock_period_ns']
        baseline = scalar_metrics(load(ROOT / 'references' / design / 'ieda/attempt-1/result.json'))
        target = scalar_metrics(load(ROOT / 'references' / design / 'inn/attempt-1/result.json'))
        for role, metrics in [('original_iEDA', baseline), ('Inn', target)]:
            gaps = reference_gaps(metrics, target, period)
            table.append({'design': design, 'role': role, 'status': 'reference', **metrics,
                          'worst_Inn_gap': gaps['worst'], 'sum_Inn_gap': gaps['sum']})
        agents = []; rules = []
        for entry in [e for e in episodes if e['design'] == design]:
            identifier = entry['id']; root = ROOT / 'episodes' / identifier
            path = root / 'result.json'; audit_path = ROOT / 'audits' / identifier / 'result.json'
            value = load(path) if path.exists() else {}
            audit = load(audit_path) if audit_path.exists() else {}
            receipt_path=ROOT/'attempt-receipts'/(identifier+'.json')
            receipt=load(receipt_path)if receipt_path.exists()else{}
            delivery = value.get('delivery'); metrics = delivery.get('metrics') if delivery else None
            valid = bool(value.get('ok') and audit.get('ok') and metrics and metrics.get('valid')
                         and assess(metrics, baseline, target)['qualified'])
            controller = entry.get('controller', 'agent')
            if delivery:
                all_deliveries_valid=all_deliveries_valid and all(audit.get('checks',{}).get(key)is True for key in('selected_candidate_passed','delivery_matches_measured_candidate','fresh_measurement_valid','fresh_metrics_reproduce'))
            cost = value.get('work', {})
            requests = root / 'traces/requests.jsonl'
            request_rows = [json.loads(s) for s in requests.read_text().splitlines() if s.strip()] if requests.exists() else []
            row = {'design': design, 'role': controller, 'episode': identifier,
                   'status': 'valid' if valid else 'failed' if value or receipt else 'pending',
                   **(metrics or {}), 'wall_s': value.get('wall_s'),
                   'API_s': sum(r.get('wall_s', 0) for r in request_rows),
                   'API_requests': value.get('model_request_count'), **cost}
            row.update({'delta_original_' + k: metrics[k] - baseline[k] for k in AXES} if metrics else {})
            gaps = reference_gaps(metrics, target, period) if metrics and metrics.get('valid') else None
            if gaps: row.update(worst_Inn_gap=gaps['worst'], sum_Inn_gap=gaps['sum'])
            table.append(row); records[identifier] = row
            item = {'entry': entry, 'valid': valid, 'metrics': metrics,
                    'rank': rank(metrics, target, period) if valid else (math.inf, math.inf)}
            (agents if controller == 'agent' else rules).append(item)
            if controller == 'agent':
                normal += valid
                delivered += bool(delivery)
            ledger = root / 'tool-ledger.jsonl'
            best = (math.inf, math.inf)
            if ledger.exists():
                for sequence, line in enumerate(ledger.read_text().splitlines()):
                    event = json.loads(line); response = event['response']; m = response.get('metrics')
                    if not m or not m.get('valid'): continue
                    qualification = assess(m, baseline, target)
                    if qualification['qualified']: best = min(best, rank(m, target, period))
                    b = response.get('budget', {})
                    curves.append({'design': design, 'controller': controller, 'episode': identifier,
                                   'tool_sequence': sequence, 'candidate': response.get('candidate_id'),
                                   'qualified': qualification['qualified'],
                                   'physical_cpu_s': b.get('physical_cpu_s'),
                                   'wall_s': plan['arms'][entry['arm']]['budget']['wall_seconds'] - b.get('remaining_wall_s', 0),
                                   'actual_gp_steps': b.get('actual_gp_steps'),
                                   'neighbor_trials': b.get('neighbor_trials_used'),
                                   'fresh_STA': b.get('fresh_sta_used'),
                                   'candidate_worst_gap': rank(m, target, period)[0],
                                   'best_measured_worst_gap_diagnostic': best[0] if math.isfinite(best[0]) else None})
        # Select an actually delivered middle run under the frozen lexicographic
        # ranking. A component-wise median is not an actual deliverable DEF.
        agents.sort(key=lambda x: (*x['rank'], x['entry']['id']))
        rules.sort(key=lambda x: (*x['rank'], x['entry']['id']))
        median = agents[1] if len(agents) == 3 else None
        strongest = rules[0] if len(rules) == 3 else None
        challenge = not matched(baseline, target)
        win = bool(median and strongest and median['valid'] and strongest['valid']
                   and better(median['rank'], strongest['rank']))
        practical = False; effect = None
        if median and strongest and median['valid'] and strongest['valid']:
            practical,effect=practical_gain(median['metrics'],strongest['metrics'],target,period)
        decisions.append({'design': design, 'holdout': design in suite.get('holdout_designs', []),
                          'challenge': challenge, 'median_actual_episode': median['entry']['id'] if median else None,
                          'strongest_rule_episode': strongest['entry']['id'] if strongest else None,
                          'agent_win': win, 'practical_gain': practical, 'effect': effect,
                          'all_runs_audited': len(agents) == 3 and len(rules) == 3 and all(x['valid'] for x in agents + rules)})
    challenge_rows = [r for r in decisions if r['challenge']]
    holdouts = [r for r in decisions if r['holdout']]
    complete = len(episodes) == 72 and all(row['status'] != 'pending' for row in records.values())
    checks = {'complete_72_main_episodes': complete,
              'every_actual_delivery_legal_identity_and_sevenaxis_audited':all_deliveries_valid,
              'at_least_35_of_36_normal_agent_deliveries': normal >= 35,
              'all_rule_deliveries_audited': all(r['status'] == 'valid' for r in records.values() if r['role'] != 'agent'),
              'at_least_60_percent_challenge_wins': bool(challenge_rows) and sum(r['agent_win'] for r in challenge_rows) >= .6 * len(challenge_rows),
              'four_holdouts_at_least_three_challenging': len(holdouts) == 4 and sum(r['challenge'] for r in holdouts) >= 3,
              'at_least_three_holdout_wins': sum(r['agent_win'] for r in holdouts) >= 3,
              'at_least_three_practical_challenge_gains': sum(r['practical_gain'] for r in challenge_rows) >= 3}
    main_pass = all(checks.values())
    winners = [r for r in decisions if r['agent_win']or(r['challenge']and r['practical_gain'])]
    value = {'main_quality_gate_passed': main_pass, 'checks': checks,
             'normal_agent_deliveries': normal, 'actual_agent_deliveries_including_failed_episodes': delivered,
             'expected_main_episodes': 72, 'completed_episode_results': sum(r['status'] != 'pending' for r in records.values()),
             'per_design': decisions, 'catchup_required': winners,
             'continue_decision': 'pending_equal_compute_catchup' if main_pass else 'attribution_required' if complete else 'validation_incomplete',
             'scope': 'Placement proxies only; no routing, signoff, or DAC acceptance claim.',
             'aggregation': 'Three-run median selects the middle actual delivery by worst-gap/sum rank; all failures retained.',
             'non_LLM_reference': 'Best actual delivery among three separately charged frozen deterministic controllers; their aggregate cost must also be disclosed.',
             'curve_semantics': 'Best measured curve is diagnostic only. Main result is the controller explicit pl_finish delivery.',
             'input_plan': desc(ROOT / 'paired-plan.json')}
    write_csv(output / 'all-deliveries.csv', table)
    write_csv(output / 'actual-cost-quality-curves.csv', curves)
    save(output / 'decision.json', value)
    print(json.dumps({'output': str(output), 'main_quality_gate_passed': main_pass,
                      'continue_decision': value['continue_decision'], 'checks': checks}), flush=True)
    return value


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--output', required=True)
    analyze(parser.parse_args().output)
