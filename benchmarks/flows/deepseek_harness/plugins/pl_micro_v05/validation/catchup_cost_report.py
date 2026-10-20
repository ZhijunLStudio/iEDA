#!/usr/bin/env python3
"""Read-only actual-cost comparison for all frozen individual-win catchups."""
import argparse
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import sys


def load(path, default=None):
    return json.loads(path.read_text()) if path.exists() else default


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(main, catchup, output):
    if output.exists():
        raise FileExistsError('Existing report is retained: ' + str(output))
    required = load(main / 'analysis-v1/decision.json')['catchup_required']
    if not required:
        raise RuntimeError('No individual-win catchup cases are required')
    cohort = load(catchup / 'cohort-result.json', {})
    if cohort.get('completed') != cohort.get('total') or cohort.get('total') != len(required):
        raise RuntimeError('Catchup cohort is not terminal with every required case; no output written')
    os.sched_setaffinity(0, {max(os.sched_getaffinity(0))})
    for name in ('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS'):
        os.environ[name] = '1'
    os.environ['IEDA_STUDY_ROOT'] = str(main)
    sys.path.insert(0, str(main))
    from study_contract import verify_study
    from release_gate import CRITICAL
    from analyze_policy_study import rank, better, practical_gain
    from pl_backend import scalar_metrics
    from surplus import AXES, assess
    verify_study(main)
    verify_study(catchup)
    for name in (*CRITICAL, 'plugin/lib/index.js'):
        if digest(main / name) != digest(catchup / name):
            raise RuntimeError('Frozen policy/physical source differs: ' + name)
    plan = load(catchup / 'paired-plan.json')
    if plan['agent'] or len(plan['rule']) != len(required):
        raise RuntimeError('Expected only frozen rule catchups')
    suite = load(main / 'suite.json')
    records, table, curves, evidence = [], [], [], []
    for specification in required:
        design = specification['design']
        entries = [entry for entry in plan['rule'] if entry['design'] == design]
        if len(entries) != 1:
            raise RuntimeError('Ambiguous catchup for ' + design)
        target = scalar_metrics(load(main / 'references' / design / 'inn/attempt-1/result.json'))
        baseline = scalar_metrics(load(main / 'references' / design / 'ieda/attempt-1/result.json'))
        period = suite['designs'][design]['clock_period_ns']
        arms = {}
        for label, study, identifier in [
            ('original_rule', main, specification['strongest_rule_episode']),
            ('agent_median', main, specification['median_actual_episode']),
            ('catchup_rule', catchup, entries[0]['id']),
        ]:
            root = study / 'episodes' / identifier
            result = load(root / 'result.json', {})
            audit = load(study / 'audits' / identifier / 'result.json', {})
            delivery = result.get('delivery') or {}
            metrics = delivery.get('metrics')
            complete_metrics = bool(metrics and metrics.get('valid') and all(
                isinstance(metrics.get(key), (int, float)) and math.isfinite(metrics[key]) for key in AXES))
            valid = bool(result.get('ok') and audit.get('ok') and complete_metrics
                         and assess(metrics, baseline, target)['qualified'])
            item = {'episode': identifier, 'normal': valid, 'has_delivery': bool(delivery),
                    'metrics': metrics, 'rank': rank(metrics, target, period) if complete_metrics else None,
                    'work': result.get('work', {}), 'wall_s': result.get('wall_s'),
                    'model_requests': result.get('model_request_count'),
                    'audit_native_CPU_s': audit.get('fresh', {}).get('terminal', {}).get('cpu_s')}
            arms[label] = item
            for path in (root / 'result.json', root / 'tool-ledger.jsonl',
                         study / 'audits' / identifier / 'result.json'):
                evidence.append({'path': str(path), 'sha256': digest(path) if path.exists() else None})
            best = None
            ledger = root / 'tool-ledger.jsonl'
            for sequence, line in enumerate(ledger.read_text().splitlines() if ledger.exists() else []):
                event = json.loads(line)
                response = event['response']
                measured = response.get('metrics')
                if event['request']['op'] not in ('legalize', 'refine', 'evaluate') or not measured or not measured.get('valid'):
                    continue
                if not assess(measured, baseline, target)['qualified']:
                    continue
                measured_rank = rank(measured, target, period)
                best = min(best, measured_rank) if best is not None else measured_rank
                budget = response.get('budget', {})
                curves.append({'design': design, 'arm': label, 'episode': identifier,
                               'sequence': sequence, 'physical_CPU_s': budget.get('physical_cpu_s'),
                               'best_measured_worst_gap_diagnostic': best[0]})
        agent, original, extra = (arms[key] for key in ('agent_median', 'original_rule', 'catchup_rule'))
        agent_cpu = agent['work'].get('physical_cpu_s')
        extra_cpu = extra['work'].get('physical_cpu_s')
        caught = isinstance(agent_cpu, (int, float)) and isinstance(extra_cpu, (int, float)) and extra_cpu >= agent_cpu
        references = [(label, item) for label, item in (('original_rule', original), ('catchup_rule', extra)) if item['normal']]
        strongest = min(references, key=lambda pair: (pair[1]['rank'], pair[0])) if references else None
        survived = bool(specification['agent_win'] and agent['normal'] and extra['normal'] and caught
                        and strongest and better(agent['rank'], strongest[1]['rank']))
        # At a ranking tie, practical benefits must hold against both references.
        tied = [item for _, item in references if strongest and item['rank'] == strongest[1]['rank']]
        practical = bool(agent['normal'] and extra['normal'] and caught and tied and all(
            practical_gain(agent['metrics'], item['metrics'], target, period)[0] for item in tied))
        record = {**specification, 'arms': arms, 'CPU_caught_up': caught,
                  'survived_frozen_rule_catchup': survived, 'practical_gain_after_catchup': practical,
                  'stronger_reference': strongest[0] if strongest else None}
        records.append(record)
        row = {key: record[key] for key in ('design', 'challenge', 'holdout', 'agent_win',
               'CPU_caught_up', 'survived_frozen_rule_catchup', 'practical_gain_after_catchup', 'stronger_reference')}
        for label, item in arms.items():
            row.update({label + '_' + key: item.get(key) for key in ('episode', 'normal', 'wall_s', 'model_requests', 'audit_native_CPU_s')})
            row[label + '_worst_Inn_gap'] = item['rank'][0] if item['rank'] else None
            row.update({label + '_' + key: item['work'].get(key) for key in
                       ('physical_cpu_s', 'actual_gp_steps', 'unobserved_GP_reserved_steps',
                        'neighbor_trials_used', 'fresh_sta_used', 'evaluation_cache_hits')})
            row.update({label + '_' + key: (item['metrics'] or {}).get(key) for key in AXES})
        table.append(row)
    output.mkdir(parents=True, exist_ok=False)
    for name, rows in [('actual-catchup-comparison.csv', table), ('actual-cost-curves.csv', curves)]:
        with (output / name).open('x', newline='') as stream:
            keys = list(dict.fromkeys(key for row in rows for key in row))
            writer = csv.DictWriter(stream, fieldnames=keys)
            writer.writeheader()
            writer.writerows(rows)
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    colors = {'original_rule': '#687580', 'agent_median': '#aa4488', 'catchup_rule': '#287db5'}
    markers = {'original_rule': 's', 'agent_median': 'o', 'catchup_rule': '^'}
    figure, axes = plt.subplots((len(records) + 2) // 3, 3, figsize=(14, 7), squeeze=False)
    for axis, record in zip(axes.flat, records):
        for label, item in record['arms'].items():
            points = [point for point in curves if point['design'] == record['design'] and point['arm'] == label
                      and point['physical_CPU_s'] is not None]
            axis.step([point['physical_CPU_s'] for point in points],
                      [point['best_measured_worst_gap_diagnostic'] for point in points],
                      where='post', ls=':', alpha=.6, color=colors[label])
            if item['rank'] is not None and item['work'].get('physical_cpu_s') is not None:
                axis.scatter(item['work']['physical_cpu_s'], item['rank'][0],
                             marker=markers[label] if item['normal'] else 'x',
                             color=colors[label] if item['normal'] else '#c43131', s=44)
        axis.set_title(record['design'] + ('\nCPU matched' if record['CPU_caught_up'] else '\nCPU NOT matched'))
        axis.set_xlabel('Actual physical CPU (s)')
        axis.set_ylabel('Worst normalized Inn gap')
        axis.grid(alpha=.2)
    for axis in list(axes.flat)[len(records):]:
        axis.set_visible(False)
    handles = [Line2D([], [], marker=markers[key], color=color, ls='', label=key)
               for key, color in colors.items()]
    handles.append(Line2D([], [], marker='x', color='#c43131', ls='', label='invalid episode'))
    figure.legend(handles=handles, loc='lower center', ncol=4)
    figure.suptitle('Markers: actual deliveries (one middle agent run). Dotted lines: best-measured diagnostics.\n'
                   'Unmatched actual CPU earns no strategy credit; GP/trials/STA and all seven axes are in CSV.', fontsize=11)
    figure.tight_layout(rect=(0, .05, 1, .93))
    figure.savefig(output / 'quality-vs-actual-CPU.png', dpi=180)
    figure.savefig(output / 'quality-vs-actual-CPU.pdf')
    plt.close(figure)
    result = {'cases': records, 'evidence': evidence, 'source_sha256': digest(Path(__file__)),
              'scope': 'Frozen main and independently audited rule followups, no trial reruns or model calls. '
                       'CPU matching alone does not prove LLM necessity or repair the main technical failure.'}
    with (output / 'summary.json').open('x') as stream:
        json.dump(result, stream, indent=2, allow_nan=False)
        stream.write('\n')
    print(json.dumps({'cases': len(records), 'output': str(output),
                      'CPU_matched': sum(record['CPU_caught_up'] for record in records),
                      'survived': sum(record['survived_frozen_rule_catchup'] for record in records)}), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--main', type=Path, required=True)
    parser.add_argument('--catchup', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    run(args.main.resolve(), args.catchup.resolve(), args.output.resolve())
